import { defineStore } from 'pinia'
import { ref, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabaseClient'

export const useChatStore = defineStore('chat', () => {
    const messages = ref([])
    const loading = ref(false)
    const error = ref(null)
    const hasMore = ref(false)
    let subscription = null

    const loadMessages = async (campaignId) => {
        loading.value = true
        error.value = null
        hasMore.value = false

        try {
            const { data, error: fetchError } = await supabase
                .from('campaign_chat_messages')
                .select('*')
                .eq('campaign_id', campaignId)
                .order('created_at', { ascending: false })
                .limit(20)

            if (fetchError) throw fetchError

            if (data) {
                messages.value = data.reverse()
                hasMore.value = data.length === 20
            } else {
                messages.value = []
                hasMore.value = false
            }
        } catch (err) {
            console.error('Error loading messages:', err)
            error.value = err.message
        } finally {
            loading.value = false
        }
    }

    const loadMoreMessages = async (campaignId) => {
        if (!messages.value.length || loading.value) return

        loading.value = true
        error.value = null

        try {
            const oldestMessage = messages.value[0]
            const { data, error: fetchError } = await supabase
                .from('campaign_chat_messages')
                .select('*')
                .eq('campaign_id', campaignId)
                .lt('created_at', oldestMessage.created_at)
                .order('created_at', { ascending: false })
                .limit(20)

            if (fetchError) throw fetchError

            if (data && data.length > 0) {
                messages.value = [...data.reverse(), ...messages.value]
                hasMore.value = data.length === 20
            } else {
                hasMore.value = false
            }
        } catch (err) {
            console.error('Error loading more messages:', err)
            error.value = err.message
        } finally {
            loading.value = false
        }
    }

    const subscribeToChat = (campaignId) => {
        if (subscription) return

        subscription = supabase
            .channel(`chat:${campaignId}`)
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'campaign_chat_messages',
                filter: `campaign_id=eq.${campaignId}`
            }, (payload) => {
                messages.value.push(payload.new)
            })
            .on('postgres_changes', {
                event: 'DELETE',
                schema: 'public',
                table: 'campaign_chat_messages',
                filter: `campaign_id=eq.${campaignId}`
            }, (payload) => {
                messages.value = messages.value.filter(m => m.id !== payload.old.id)
            })
            .subscribe()
    }

    const unsubscribeChat = () => {
        if (subscription) {
            supabase.removeChannel(subscription)
            subscription = null
        }
    }

    const sendMessage = async (campaignId, content, recipientId = null) => {
        if (!content.trim()) return

        try {
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) throw new Error('Not authenticated')

            const message = {
                campaign_id: campaignId,
                user_id: user.id,
                content: content,
                recipient_id: recipientId
            }

            const { error: sendError } = await supabase
                .from('campaign_chat_messages')
                .insert(message)

            if (sendError) throw sendError

            return { success: true }
        } catch (err) {
            console.error('Error sending message:', err)
            return { success: false, error: err.message }
        }
    }

    const deleteMessage = async (messageId) => {
        try {
            const { error: deleteError } = await supabase
                .from('campaign_chat_messages')
                .delete()
                .eq('id', messageId)

            if (deleteError) throw deleteError
            return { success: true }
        } catch (err) {
            console.error('Error deleting message:', err)
            return { success: false, error: err.message }
        }
    }

    // Cleanup when store is disposed? Pinia stores are usually global, 
    // but we can expose cleanup actions.
    // Ideally components call unsubscribe on Unmount, but since this is global 
    // we should be careful. 
    // For now we expose unsubscribeChat.

    return {
        messages,
        loading,
        error,
        hasMore,
        loadMessages,
        loadMoreMessages,
        subscribeToChat,
        unsubscribeChat,
        sendMessage,
        deleteMessage
    }
})
