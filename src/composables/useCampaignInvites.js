import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'

export function useCampaignInvites() {
    const loading = ref(false)
    const error = ref(null)

    /**
     * Send invitation to a player
     * @param {string} campaignId - Campaign UUID
     * @param {string} usernameOrEmail - Username or email of player to invite
     */
    const sendInvite = async (campaignId, usernameOrEmail) => {
        loading.value = true
        error.value = null

        try {
            // Get current user
            const { data: { user } } = await supabase.auth.getUser()
            if (!user) throw new Error('Not authenticated')

            // Check if invitation already exists
            const { data: existing } = await supabase
                .from('campaign_invitations')
                .select('*')
                .eq('campaign_id', campaignId)
                .eq('username_or_email', usernameOrEmail)
                .in('status', ['pending', 'accepted'])
                .single()

            if (existing) {
                throw new Error('Invitation already exists for this user')
            }

            // Create invitation
            const { data: result, error: insertError } = await supabase
                .from('campaign_invitations')
                .insert({
                    campaign_id: campaignId,
                    invited_by: user.id,
                    username_or_email: usernameOrEmail,
                    status: 'pending'
                })
                .select()
                .single()

            if (insertError) throw insertError

            return { success: true, data: result }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Get all invitations for a campaign
     * @param {string} campaignId - Campaign UUID
     */
    const getInvitations = async (campaignId) => {
        loading.value = true
        error.value = null

        try {
            const { data, error: fetchError } = await supabase
                .from('campaign_invitations')
                .select('*')
                .eq('campaign_id', campaignId)
                .order('created_at', { ascending: false })

            if (fetchError) throw fetchError

            return { success: true, data: data || [] }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message, data: [] }
        } finally {
            loading.value = false
        }
    }

    /**
     * Revoke a pending invitation
     * @param {string} inviteId - Invitation UUID
     */
    const revokeInvite = async (inviteId) => {
        loading.value = true
        error.value = null

        try {
            const { data: result, error: updateError } = await supabase
                .from('campaign_invitations')
                .update({ status: 'revoked', updated_at: new Date().toISOString() })
                .eq('id', inviteId)
                .select()
                .single()

            if (updateError) throw updateError

            return { success: true, data: result }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Get all members of a campaign
     * @param {string} campaignId - Campaign UUID
     */
    /**
     * Get all members of a campaign
     * @param {string} campaignId - Campaign UUID
     */
    const getMembers = async (campaignId) => {
        loading.value = true
        error.value = null

        try {
            // Use RPC function to get members with details (email, etc)
            const { data, error: fetchError } = await supabase
                .rpc('get_campaign_members_details', { campaign_id_input: campaignId })

            if (fetchError) throw fetchError

            return { success: true, data: data || [] }
        } catch (err) {
            console.error('Error fetching members:', err)
            error.value = err.message
            return { success: false, error: err.message, data: [] }
        } finally {
            loading.value = false
        }
    }

    /**
     * Remove a member from campaign
     * @param {string} campaignId - Campaign UUID
     * @param {string} userId - User UUID to remove
     */
    const removeMember = async (campaignId, userId) => {
        loading.value = true
        error.value = null

        try {
            const { error: deleteError } = await supabase
                .from('campaign_members')
                .delete()
                .eq('campaign_id', campaignId)
                .eq('user_id', userId)

            if (deleteError) throw deleteError

            return { success: true }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Add a member to campaign (used when accepting invitations)
     * @param {string} campaignId - Campaign UUID
     * @param {string} userId - User UUID to add
     * @param {string} role - Role (master/player)
     */
    const addMember = async (campaignId, userId, role = 'player') => {
        loading.value = true
        error.value = null

        try {
            const { data: result, error: insertError } = await supabase
                .from('campaign_members')
                .insert({
                    campaign_id: campaignId,
                    user_id: userId,
                    role
                })
                .select()
                .single()

            if (insertError) throw insertError

            return { success: true, data: result }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Get invitation by token
     * @param {string} token - Invitation token UUID
     */
    const getInviteByToken = async (token) => {
        loading.value = true
        error.value = null

        try {
            // Use RPC function to bypass RLS policies safely
            const { data, error: rpcError } = await supabase
                .rpc('get_invitation_details', { token_input: token })
                .single()

            if (rpcError) throw rpcError
            if (!data) throw new Error('Invitation not found')

            // Transform data to match expected structure
            const result = {
                id: data.id,
                status: data.status,
                username_or_email: data.username_or_email,
                campaign_id: data.campaign_id,
                invited_by_email: data.invited_by_email,
                campaign: {
                    id: data.campaign_id,
                    name: data.campaign_name,
                    description: data.campaign_description,
                    cover_photo: data.campaign_cover_photo
                }
            }

            return { success: true, data: result }
        } catch (err) {
            console.error('Error fetching invitation:', err)
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Accept invitation by token
     * @param {string} token - Invitation token UUID
     */
    const acceptInvite = async (token) => {
        loading.value = true
        error.value = null

        try {
            // Use RPC function to accept invitation atomically
            // This bypasses RLS for member insertion and status update
            const { data, error: rpcError } = await supabase
                .rpc('accept_invitation', { token_input: token })

            if (rpcError) throw rpcError

            // RPC returns { success: boolean, error?: string, campaignId?: string }
            if (!data.success) {
                throw new Error(data.error)
            }

            return {
                success: true,
                campaignId: data.campaignId
            }
        } catch (err) {
            console.error('Error accepting invitation:', err)
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    return {
        loading,
        error,
        sendInvite,
        getInvitations,
        revokeInvite,
        getMembers,
        removeMember,
        addMember,
        getInviteByToken,
        acceptInvite
    }
}
