<template>
    <div class="h-screen w-screen bg-[#00FF00] flex items-center justify-center overflow-hidden relative">
        <!-- Image Container with Transition -->
        <transition name="fade">
            <div v-if="currentImage" class="relative max-h-screen max-w-screen p-4">
                <img :src="currentImage.url" class="max-h-[90vh] max-w-[90vw] object-contain shadow-2xl rounded-lg"
                    style="box-shadow: 0 0 50px rgba(0,0,0,0.5);">

                <!-- Optional: Name Label (can be enabled/disabled if needed) -->
                <div v-if="currentImage.displayName"
                    class="absolute bottom-8 left-1/2 -translate-x-1/2 bg-black/70 text-white px-6 py-2 rounded-full text-2xl font-bold backdrop-blur-md">
                    {{ currentImage.displayName }}
                </div>
            </div>
        </transition>

    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import { useStorage } from '../composables/useStorage'

const route = useRoute()
const sessionId = route.params.id

const { storage, setConfig } = useStorage()

const currentImage = ref(null)
const isConnected = ref(false)

onMounted(async () => {
    if (!sessionId) return

    // 0. Initialize Storage
    const { data: session } = await supabase
        .from('sessions')
        .select('storage_provider, storage_config')
        .eq('id', sessionId)
        .single()

    if (session) {
        setConfig(session.storage_provider || 'supabase', session.storage_config || {})
    }

    setupRealtime()
})

const setupRealtime = () => {
    const channel = supabase.channel(`session_${sessionId}`)

    channel
        .on('broadcast', { event: 'show_image' }, ({ payload }) => {
            if (payload && (payload.url || payload.imgName)) {
                let url = payload.url

                // Fallback for legacy broadcasts or if url missing
                if (!url && payload.imgName) {
                    const path = payload.path || `sessions/${sessionId}/${payload.imgName}`
                    url = storage.value.getUrl(path)
                }

                // Replace current image with new one
                currentImage.value = {
                    url: url,
                    displayName: payload.displayName || getDisplayName(payload.imgName)
                }
            }
        })
        .on('broadcast', { event: 'hide_image' }, () => {
            // Clear screen
            currentImage.value = null
        })
        .on('broadcast', { event: 'hide_image_stream' }, () => {
            // Clear screen (Specific command)
            currentImage.value = null
        })
        .subscribe((status) => {
            if (status === 'SUBSCRIBED') isConnected.value = true
        })
}

const getDisplayName = (fullName) => {
    const parts = fullName.split('_')
    if (parts.length > 1 && !isNaN(parts[0])) {
        return parts.slice(1).join('_')
    }
    return fullName
}
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.5s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}
</style>
