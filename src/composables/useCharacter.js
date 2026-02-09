import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'

// Global state for caching if needed, or scoped per component
// For simplicity, let's keep it scoped but reusable

export function useCharacter() {
    const loading = ref(false)
    const error = ref(null)
    const character = ref(null)

    // Fetch the character for the current user in a specific campaign
    const fetchCharacter = async (campaignId, userId) => {
        if (!campaignId || !userId) return null

        loading.value = true
        error.value = null
        try {
            const { data, error: dbError } = await supabase
                .from('characters')
                .select('*')
                .eq('campaign_id', campaignId)
                .eq('user_id', userId)
                .maybeSingle() // Returns null if not found instead of error

            if (dbError) throw dbError

            character.value = data
            return data
        } catch (e) {
            console.error('Error fetching character:', e)
            error.value = e.message
            return null
        } finally {
            loading.value = false
        }
    }

    // Create or Update character
    const upsertCharacter = async (characterData) => {
        loading.value = true
        error.value = null

        try {
            // Prepare data
            const payload = {
                campaign_id: characterData.campaign_id,
                user_id: characterData.user_id,
                name: characterData.name,
                class: characterData.class || null,
                race: characterData.race || null,
                level: characterData.level || 1,
                avatar_url: characterData.avatar_url || null,
                updated_at: new Date()
            }

            // If updating existing
            if (characterData.id) {
                payload.id = characterData.id
            }

            const { data, error: dbError } = await supabase
                .from('characters')
                .upsert(payload)
                .select()
                .single()

            if (dbError) throw dbError

            character.value = data
            return data
        } catch (e) {
            console.error('Error saving character:', e)
            error.value = e.message
            throw e
        } finally {
            loading.value = false
        }
    }

    // Helper to get ALL characters in a campaign (for chat name resolution)
    const fetchCampaignCharacters = async (campaignId) => {
        try {
            const { data, error } = await supabase
                .from('characters')
                .select('user_id, name, avatar_url')
                .eq('campaign_id', campaignId)

            if (error) throw error
            return data || []
        } catch (e) {
            console.error('Error fetching campaign characters:', e)
            return []
        }
    }

    return {
        character,
        loading,
        error,
        fetchCharacter,
        upsertCharacter,
        fetchCampaignCharacters
    }
}
