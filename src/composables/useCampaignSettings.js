import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { useStorage } from './useStorage'

export function useCampaignSettings() {
    const loading = ref(false)
    const error = ref(null)
    const { storage } = useStorage()

    /**
     * Update campaign information
     * @param {string} campaignId - Campaign UUID
     * @param {Object} data - Campaign data to update
     * @param {string} data.name - Campaign name
     * @param {string} data.description - Campaign description
     * @param {string} data.cover_photo - Cover photo URL
     * @param {string} data.start_date - Start date (YYYY-MM-DD)
     */
    const updateCampaignInfo = async (campaignId, data) => {
        loading.value = true
        error.value = null

        try {
            const { data: result, error: updateError } = await supabase
                .from('sessions')
                .update(data)
                .eq('id', campaignId)
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
     * Toggle campaign open/closed status
     * @param {string} campaignId - Campaign UUID
     * @param {boolean} isOpen - Whether campaign is open for new players
     */
    const toggleCampaignStatus = async (campaignId, isOpen) => {
        loading.value = true
        error.value = null

        try {
            const { data: result, error: updateError } = await supabase
                .from('sessions')
                .update({ is_open: isOpen })
                .eq('id', campaignId)
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
     * Upload cover photo for campaign
     * @param {File} file - Image file to upload
     * @param {string} campaignId - Campaign UUID
     */
    const uploadCoverPhoto = async (file, campaignId) => {
        loading.value = true
        error.value = null

        try {
            // Generate unique filename
            const fileExt = file.name.split('.').pop()
            const fileName = `cover-${campaignId}-${Date.now()}.${fileExt}`
            const filePath = `campaigns/${campaignId}/${fileName}`

            // Upload to storage
            const uploadResult = await storage.value.upload(file, filePath)

            if (uploadResult.error) {
                throw new Error(uploadResult.error.message || 'Upload failed')
            }

            // Get public URL
            const publicUrl = uploadResult.url

            // Update campaign with cover photo URL
            const { data: result, error: updateError } = await supabase
                .from('sessions')
                .update({ cover_photo: publicUrl })
                .eq('id', campaignId)
                .select()
                .single()

            if (updateError) throw updateError

            return { success: true, url: publicUrl, data: result }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    /**
     * Get campaign details
     * @param {string} campaignId - Campaign UUID
     */
    const getCampaignDetails = async (campaignId) => {
        loading.value = true
        error.value = null

        try {
            const { data, error: fetchError } = await supabase
                .from('sessions')
                .select('*')
                .eq('id', campaignId)
                .single()

            if (fetchError) throw fetchError

            return { success: true, data }
        } catch (err) {
            error.value = err.message
            return { success: false, error: err.message }
        } finally {
            loading.value = false
        }
    }

    return {
        loading,
        error,
        updateCampaignInfo,
        toggleCampaignStatus,
        uploadCoverPhoto,
        getCampaignDetails
    }
}
