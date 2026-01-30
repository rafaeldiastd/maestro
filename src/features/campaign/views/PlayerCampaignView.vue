<template>
  <div class="min-h-screen bg-lumina-bg text-lumina-text flex flex-col">

    <!-- Connection Status -->
    <div
      class="fixed top-4 right-4 z-50 flex items-center gap-2 rounded-full border border-lumina-border bg-lumina-card/90 px-3 py-1.5 text-xs backdrop-blur-md shadow-sm transition-opacity hover:opacity-100"
      :class="isConnected ? 'opacity-50 hover:opacity-100' : 'text-yellow-500 border-yellow-900/30 bg-yellow-950/30'">
      <div v-if="isConnected" class="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]"></div>
      <div v-else class="h-2 w-2 rounded-full bg-yellow-500 animate-pulse"></div>
      <span class="font-medium">{{ isConnected ? 'Connected' : 'Connecting...' }}</span>
    </div>

    <!-- Main Content -->
    <main class="flex-1 p-6 md:p-8 bg-lumina-bg">

      <!-- Header (Optional, for context) -->
      <div class="mb-8 flex items-center justify-between border-b border-lumina-border pb-4">
        <h1 class="text-2xl font-serif font-bold tracking-tight text-lumina-detail">Session Gallery</h1>
      </div>

      <div v-if="error" class="flex flex-col items-center justify-center pt-24 text-center">
        <div class="rounded-full bg-red-900/20 p-4 mb-4">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-red-500">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
        </div>
        <h2 class="text-lg font-semibold text-zinc-200">{{ error.title }}</h2>
        <p class="text-sm text-zinc-500 mt-1 mb-6 max-w-xs mx-auto">{{ error.msg }}</p>
        <a href="/" class="text-xs font-medium text-zinc-400 hover:text-white underline underline-offset-4 decoration-zinc-700 hover:decoration-white transition-all">Go to Home</a>
      </div>

      <div v-else-if="loading" class="flex flex-col items-center justify-center pt-32 gap-3">
        <div class="h-6 w-6 animate-spin rounded-full border-2 border-zinc-600 border-t-zinc-200"></div>
        <p class="text-xs font-mono text-zinc-500 animate-pulse">SYNCING ASSETS...</p>
      </div>

      <div v-else-if="images.length === 0" class="flex flex-col items-center justify-center pt-40">
        <div class="p-6 rounded-full bg-zinc-900/50 mb-4 border border-lumina-border">
           <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="text-zinc-600">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
              <circle cx="8.5" cy="8.5" r="1.5"></circle>
              <polyline points="21 15 16 10 5 21"></polyline>
            </svg>
        </div>
        <p class="text-sm font-medium text-zinc-400">Nothing here yet</p>
        <p class="text-xs text-zinc-600 mt-1">Waiting for the Master to reveal images...</p>
      </div>

      <div v-else class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
        <div v-for="img in images" :key="img.name"
          class="group relative aspect-square cursor-pointer overflow-hidden rounded-xl bg-lumina-card ring-1 ring-lumina-border transition-all hover:ring-lumina-detail hover:shadow-lg"
          @click="openLightbox(img)">
          
          <img :src="img.url" loading="lazy" class="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105">
          
          <!-- Gradient Overlay -->
          <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent p-4 opacity-0 transition-opacity duration-300 group-hover:opacity-100 flex items-end">
             <p class="truncate text-xs font-medium text-zinc-100 w-full">
              {{ img.displayName }}
            </p>
          </div>
        </div>
      </div>
    </main>

    <Lightbox :isOpen="!!lightboxAsset" :imageUrl="lightboxAsset ? lightboxAsset.url : ''"
      :title="lightboxAsset ? lightboxAsset.displayName : ''" :showBroadcast="false" @close="closeLightbox" />
    
    <!-- Realtime Chat Sidebar -->
    <ChatSidebar
      v-if="currentUserId"
      :campaign-id="sessionId"
      :current-user-id="currentUserId"
      :is-owner="false"
      :is-open="isChatOpen"
      @toggle="isChatOpen = !isChatOpen"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router' // Added useRouter for auth redirect if needed
import { supabase } from '@/lib/supabaseClient'
import Lightbox from '@/components/shared/Lightbox.vue'
import ChatSidebar from '@/features/chat/components/ChatSidebar.vue' // [NEW]

import { useStorage } from '@/composables/useStorage'

const route = useRoute()
const router = useRouter() // [NEW]
const sessionId = route.params.id // Using params from /join/:id

const { storage, setConfig } = useStorage()

const images = ref([])
const loading = ref(true)
const error = ref(null)
const isConnected = ref(false)
const lightboxAsset = ref(null)

const currentUserId = ref(null) // [NEW]
const isChatOpen = ref(true) // [NEW]

onMounted(async () => {
  if (!sessionId) {
    error.value = { title: 'Invalid Link', msg: 'Missing Session ID.' }
    loading.value = false
    return
  }
  
  // Check Auth & Set User [NEW]
  const { data: { user } } = await supabase.auth.getUser()
  if (user) {
    currentUserId.value = user.id
  } else {
    // If not logged in, maybe redirect to login? 
    // Or allow anonymous if that was the plan (but chat needs auth).
    // For now assuming player must be logged in.
    // router.push('/') // Optional: redirect if auth required
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

</script>
