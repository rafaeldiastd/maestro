import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabaseClient'

// Global State (Singleton)
const participants = ref([])
const loading = ref(false)
const error = ref(null)
const currentRound = ref(1)
const activeIndex = ref(0)
const isCapturing = ref(false) // Shared capturing state
let subscription = null

export function useInitiative() {

    // --- Actions ---

    /**
     * Save current state to DB (Debounce if needed, but direct for now)
     */
    const save = async (sessionId) => {
        if (!sessionId) return

        const payload = {
            session_id: sessionId,
            participants: participants.value,
            round: currentRound.value,
            current_turn_index: activeIndex.value,
            updated_at: new Date()
        }

        try {
            const { error: upsertError } = await supabase
                .from('campaign_initiatives')
                .upsert(payload, { onConflict: 'session_id' })

            if (upsertError) throw upsertError
        } catch (err) {
            console.error('Error saving initiative (DB):', err)
            error.value = err.message
        }
    }

    /**
     * Add or Update Participant
     */
    const addParticipant = (participant, sessionId) => {
        // Check for duplicate by ID or Name (if Name and same value, update?)
        // Logic: if ID exists, update. If Name exists, confirm? (Confirm handled in UI usually).
        // Here we assume "Force Add/Update" logic.

        const existingIdx = participants.value.findIndex(p => p.id === participant.id)

        if (existingIdx !== -1) {
            participants.value[existingIdx] = { ...participants.value[existingIdx], ...participant }
        } else {
            // Check by Name for capture logic merge
            const sameName = participants.value.find(p => p.name === participant.name)
            if (sameName) {
                sameName.total = participant.total
            } else {
                participants.value.push(participant)
            }
        }

        // Auto-sort? Optional.
        // participants.value.sort((a, b) => b.total - a.total)

        save(sessionId)
    }

    const removeParticipant = (id, sessionId) => {
        participants.value = participants.value.filter(p => p.id !== id)
        save(sessionId)
    }

    const updateParticipantsList = (newList, sessionId) => {
        participants.value = newList
        save(sessionId)
    }

    const nextTurn = (sessionId) => {
        if (participants.value.length === 0) return

        activeIndex.value = (activeIndex.value + 1) % participants.value.length
        if (activeIndex.value === 0) {
            currentRound.value++
        }
        save(sessionId)
    }

    const clearInitiative = (sessionId) => {
        participants.value = []
        currentRound.value = 1
        activeIndex.value = 0
        save(sessionId)
    }

    /**
     * Fetch initiative state for a session
     */
    const fetchInitiative = async (sessionId) => {
        loading.value = true
        try {
            const { data, error: fetchError } = await supabase
                .from('campaign_initiatives')
                .select('*')
                .eq('session_id', sessionId)
                .maybeSingle()

            if (fetchError) throw fetchError

            if (data) {
                participants.value = data.participants || []
                currentRound.value = data.round || 1
                activeIndex.value = data.current_turn_index || 0
            } else {
                participants.value = []
                currentRound.value = 1
                activeIndex.value = 0
            }
        } catch (err) {
            console.error('Error fetching initiative:', err)
            error.value = err.message
        } finally {
            loading.value = false
        }
    }

    /**
     * Subscribe to realtime updates
     */
    const subscribeToInitiative = (sessionId) => {
        if (subscription) return

        subscription = supabase
            .channel(`initiative:${sessionId}`)
            .on('postgres_changes', {
                event: '*',
                schema: 'public',
                table: 'campaign_initiatives',
                filter: `session_id=eq.${sessionId}`
            }, (payload) => {
                if (payload.new) {
                    // Update local state from DB change (e.g. valid broadcast)
                    // Avoid loop if we just saved? Realtime usually echoes.
                    // Ideally check timestamp or user ID but for now sync is safer.
                    participants.value = payload.new.participants || []
                    currentRound.value = payload.new.round || 1
                    activeIndex.value = payload.new.current_turn_index || 0
                }
            })
            .subscribe()
    }

    const unsubscribeInitiative = () => {
        if (subscription) {
            supabase.removeChannel(subscription)
            subscription = null
        }
    }

    return {
        // State
        participants,
        loading,
        error,
        currentRound,
        activeIndex,
        isCapturing, // Shared toggle

        // Actions
        fetchInitiative,
        addParticipant,
        removeParticipant,
        updateParticipantsList,
        nextTurn,
        clearInitiative,
        subscribeToInitiative,
        unsubscribeInitiative
    }
}
