<template>
  <div class="min-h-screen bg-lumina-bg text-lumina-text flex flex-col">

    <!-- Connection Status -->
    <div
      class="fixed top-4 right-4 z-50 flex items-center gap-2 rounded-full bg-black/50 px-3 py-1 text-xs backdrop-blur-md transition-opacity hover:opacity-100"
      :class="isConnected ? 'opacity-30' : 'text-yellow-400'">
      <div v-if="isConnected" class="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]"></div>
      <div v-else class="h-2 w-2 rounded-full bg-yellow-500 animate-pulse"></div>
      {{ isConnected ? 'Connected' : 'Connecting...' }}
    </div>

    <!-- Main Content -->
    <main class="flex-1 p-4 bg-lumina-bg">

      <div v-if="error" class="flex flex-col items-center justify-center pt-20 text-red-400 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"></circle>
          <line x1="12" y1="8" x2="12" y2="12"></line>
          <line x1="12" y1="16" x2="12.01" y2="16"></line>
        </svg>
        <h2 class="mt-4 text-lg font-semibold">{{ error.title }}</h2>
        <p class="text-sm opacity-80">{{ error.msg }}</p>
        <a href="/" class="mt-4 text-stone-400 hover:text-white underline text-sm">Create your own session</a>
      </div>

      <div v-else-if="loading" class="flex justify-center pt-20">
        <div class="h-8 w-8 animate-spin rounded-full border-4 border-stone-500 border-t-transparent"></div>
      </div>

      <div v-else-if="images.length === 0" class="flex flex-col items-center justify-center pt-40 text-slate-600">
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
          <circle cx="8.5" cy="8.5" r="1.5"></circle>
          <polyline points="21 15 16 10 5 21"></polyline>
        </svg>
        <p class="mt-4">Waiting for Master to reveal images...</p>
      </div>

      <div v-else class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
        <div v-for="img in images" :key="img.name"
          class="aspect-square cursor-pointer overflow-hidden rounded-lg bg-slate-800 ring-1 ring-slate-700 transition-all hover:ring-stone-400 hover:scale-105 relative group"
          @click="openLightbox(img)">
          <img :src="img.url" loading="lazy" class="h-full w-full object-cover">
          <div class="absolute bottom-0 inset-x-0 bg-black/60 p-1 text-xs text-white text-center truncate">
            {{ img.displayName }}
          </div>
        </div>
      </div>
    </main>

    <Lightbox :isOpen="!!lightboxAsset" :imageUrl="lightboxAsset ? lightboxAsset.url : ''"
      :title="lightboxAsset ? lightboxAsset.displayName : ''" :showBroadcast="false" @close="closeLightbox" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import Lightbox from '../components/Lightbox.vue'

import { useStorage } from '../composables/useStorage'

const route = useRoute()
const sessionId = route.params.id // Using params from /join/:id

const { storage, setConfig } = useStorage()

const images = ref([])
const loading = ref(true)
const error = ref(null)
const isConnected = ref(false)

onMounted(async () => {
  if (!sessionId) {
    error.value = { title: 'Invalid Link', msg: 'Missing Session ID.' }
    loading.value = false
    return
  }

  // 0. Initialize Storage for this Session
  const { data: session } = await supabase
    .from('sessions')
    .select('storage_provider, storage_config')
    .eq('id', sessionId)
    .single()

  if (session) {
    setConfig(session.storage_provider || 'supabase', session.storage_config || {})
  }

  // 1. Load History
  await loadHistory()

  // 2. Setup Realtime Broadcast Listener
  setupRealtime()
})

const loadHistory = async () => {
  try {
    // Query session_assets (Public RLS)
    const { data, error: dbError } = await supabase
      .from('session_assets')
      .select('file_name, storage_path, display_name') // Fetch display_name
      .eq('session_id', sessionId)
      .eq('is_revealed', true)
      .order('created_at', { ascending: true })

    if (dbError) throw dbError

    if (data && data.length > 0) {
      data.forEach(asset => addImage(asset.file_name, asset.storage_path, false, asset.display_name))
    }
  } catch (e) {
    console.error('Loader Error:', e.message)
  } finally {
    loading.value = false
  }
}

const setupRealtime = () => {
  const channel = supabase.channel(`session_${sessionId}`)

  channel
    .on('broadcast', { event: 'show_image' }, ({ payload }) => {
      console.log('Show received:', payload)
      if (payload && payload.imgName) {
        const path = payload.path || `sessions/${sessionId}/${payload.imgName}`
        const dName = payload.displayName || null
        addImage(payload.imgName, path, true, dName)
      }
    })
    .on('broadcast', { event: 'hide_image' }, ({ payload }) => {
      if (payload && payload.imgName) {
        removeImage(payload.imgName)
      }
    })
    .subscribe((status) => {
      if (status === 'SUBSCRIBED') isConnected.value = true
    })
}

const addImage = (name, path, open = false, displayName = null) => {
  // Check dupe
  const existing = images.value.find(img => img.name === name)
  if (existing) {
    // Update name on re-broadcast
    if (displayName) existing.displayName = displayName
    if (open) openLightbox(existing)
    return
  }

  // Get Public URL
  const publicUrl = storage.value.getUrl(path)

  const imgObj = {
    name: name,
    displayName: displayName || getDisplayName(name), // Fallback
    url: publicUrl
  }

  images.value.push(imgObj)

  if (open) openLightbox(imgObj)
}

const getDisplayName = (fullName) => {
  const parts = fullName.split('_')
  if (parts.length > 1 && !isNaN(parts[0])) {
    return parts.slice(1).join('_')
  }
  return fullName
}

const removeImage = (name) => {
  images.value = images.value.filter(img => img.name !== name)
  if (lightboxAsset.value && lightboxAsset.value.name === name) {
    closeLightbox()
  }
}

const openLightbox = (img) => lightboxAsset.value = img
const closeLightbox = () => lightboxAsset.value = null
const lightboxAsset = ref(null)

</script>
