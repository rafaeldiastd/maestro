<template>
  <div class="flex h-screen w-screen bg-lumina-bg text-lumina-text overflow-hidden">

    <!-- Sidebar -->
    <aside class="flex w-64 flex-col border-r border-slate-800 bg-slate-900/50 backdrop-blur-md">
      <!-- Brand -->
      <div class="p-6 border-b border-slate-800">
        <button @click="$router.push('/dashboard')"
          class="flex items-center gap-2 text-slate-400 hover:text-white transition-colors mb-2 text-xs uppercase tracking-wider font-bold">
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m15 18-6-6 6-6" />
          </svg>
          Back to Dashboard
        </button>
        <h1
          class="text-xl font-bold tracking-tight bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
          {{ sessionName || 'Loading...' }}
          <span class="text-xs font-normal text-slate-500 block">Session Control</span>
        </h1>
      </div>

      <!-- Controls -->
      <div class="flex-1 overflow-y-auto p-4 space-y-6">

        <!-- Droppable Uploader -->
        <div
          class="group relative flex h-32 w-full cursor-pointer flex-col items-center justify-center rounded-lg border-2 border-dashed border-slate-700 bg-slate-800/50 transition-colors hover:border-indigo-500 hover:bg-slate-800"
          :class="isUploading ? 'pointer-events-none opacity-50' : ''" @click="$refs.fileInput.click()"
          @dragover.prevent @drop.prevent="onFileDrop">
          <input type="file" ref="fileInput" multiple hidden @change="onFileChange" accept="image/*">

          <div v-if="isUploading" class="flex flex-col items-center gap-2">
            <div class="h-6 w-6 animate-spin rounded-full border-2 border-indigo-500 border-t-transparent"></div>
            <span class="text-xs font-medium text-slate-400">{{ uploadStatus }}</span>
          </div>
          <div v-else class="flex flex-col items-center gap-2 text-slate-400 group-hover:text-indigo-400">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="17 8 12 3 7 8"></polyline>
              <line x1="12" y1="3" x2="12" y2="15"></line>
            </svg>
            <span class="text-xs font-medium uppercase tracking-wider">Upload / Drop</span>
          </div>
        </div>

        <!-- Session Code -->
        <div class="rounded bg-indigo-500/10 border border-indigo-500/20 p-3 space-y-2">
          <div class="flex items-center justify-between text-xs font-semibold uppercase tracking-wider text-indigo-200">
            <span class="font-mono">{{ sessionId }}</span>
          </div>

          <button @click="copyJoinLink"
            class="w-full rounded bg-indigo-600/20 py-1.5 text-xs font-medium text-indigo-300 hover:bg-indigo-600/30 transition-colors flex items-center justify-center gap-2">
            <svg v-if="!linkCopied" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
              <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
            {{ linkCopied ? 'Link Copied!' : 'Copy Player Link' }}
          </button>
        </div>

        <div class="space-y-1">
          <p class="text-xs font-semibold uppercase tracking-wider text-slate-500">Settings</p>
          <button @click="endSession"
            class="flex w-full items-center gap-2 rounded px-2 py-1.5 text-xs text-red-400 hover:bg-slate-800 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
              <polyline points="16 17 21 12 16 7"></polyline>
              <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            End Session
          </button>
        </div>

      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-w-0">

      <!-- Toolbar -->
      <header
        class="flex h-14 items-center justify-between border-b border-slate-800 px-6 bg-lumina-bg/80 backdrop-blur">
        <div class="flex items-center gap-4 text-sm font-medium text-slate-400">
          <button @click="viewMode = 'grid'"
            :class="viewMode === 'grid' ? 'text-indigo-400' : 'hover:text-white'">Grid</button>
          <button @click="viewMode = 'small'"
            :class="viewMode === 'small' ? 'text-indigo-400' : 'hover:text-white'">Small</button>
          <div class="h-4 w-px bg-slate-700"></div>
          <button @click="toggleBlur" :class="blurMode ? 'text-yellow-400' : 'hover:text-white'"
            class="flex items-center gap-1">
            <svg v-if="blurMode" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24"
              fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path
                d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24">
              </path>
              <line x1="1" y1="1" x2="23" y2="23"></line>
            </svg>
            {{ blurMode ? 'Blur On' : 'Blur Off' }}
          </button>
        </div>
        <div class="text-xs text-slate-500">
          {{ assets.length }} Assets
        </div>
      </header>

      <!-- Grid area -->
      <div class="flex-1 overflow-y-auto p-6 scrollbar-thin scrollbar-track-slate-900 scrollbar-thumb-slate-700"
        @dragover.prevent @drop.prevent="onFileDrop"> <!-- Allow dropping anywhere -->

        <div v-if="assets.length === 0" class="flex h-full flex-col items-center justify-center text-slate-500">
          <p class="text-sm">No images yet. Drop files anywhere to upload.</p>
        </div>

        <div v-else :class="gridClasses" class="grid gap-4 pb-20">
          <div v-for="asset in assets" :key="asset.id"
            class="group relative overflow-hidden rounded-lg bg-slate-800 ring-1 transition-all cursor-pointer"
            :class="getCardClasses(asset)" @click="openLightbox(asset)">

            <!-- Status Indicators -->
            <div class="absolute top-2 right-2 z-10 flex gap-1">
              <span v-if="asset.is_revealed"
                class="flex items-center justify-center h-6 w-6 rounded-full bg-green-500 text-white shadow-lg"
                title="Live to Players">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
                  <circle cx="12" cy="12" r="3"></circle>
                </svg>
              </span>
            </div>

            <!-- Image -->
            <div class="aspect-square w-full overflow-hidden bg-slate-900">
              <img :src="getAssetUrl(asset)" loading="lazy"
                class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105"
                :class="{ 'blur-md': blurMode, 'opacity-50 grayscale': !asset.is_revealed }">
            </div>

            <!-- Name/Overlay -->
            <div
              class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/90 to-transparent p-3 opacity-0 transition-opacity group-hover:opacity-100 flex items-end justify-between">
              <p class="truncate text-xs font-medium text-white max-w-[70%]">{{ asset.display_name ||
                getDisplayName(asset.file_name) }}</p>

              <button @click.stop="renameAsset(asset)" title="Rename" class="text-slate-400 hover:text-white pb-0.5">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
                </svg>
              </button>
            </div>

            <!-- Delete Action (Hover) -->
            <button @click.stop="deleteAsset(asset)"
              class="absolute top-2 left-2 p-1 rounded bg-black/50 text-white opacity-0 group-hover:opacity-100 hover:bg-red-500/80 transition-all">
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="3 6 5 6 21 6"></polyline>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>

    </main>

    <Lightbox :isOpen="!!lightboxAsset" :imageUrl="lightboxAsset ? getAssetUrl(lightboxAsset) : ''"
      :showBroadcast="true" :isRevealed="lightboxAsset?.is_revealed" :isStreamHidden="streamHiddenState"
      @close="closeLightbox" @broadcast="broadcastImage" @hide="hideImage" @hide-stream="hideImageFromStream"
      @show-stream="restoreStream" />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import imageCompression from 'browser-image-compression'
import Lightbox from '../components/Lightbox.vue'

// --- State ---
const route = useRoute()
const router = useRouter()
const sessionId = route.params.id

const sessionName = ref('')
const assets = ref([]) // Source of Truth (DB records)
const viewMode = ref('grid')
const blurMode = ref(false)
const lightboxAsset = ref(null)
const streamHiddenState = ref(false)

const bucketName = 'images'
const channel = ref(null)

// Upload State
const isUploading = ref(false)
const uploadStatus = ref('')
const linkCopied = ref(false)

// --- Lifecycle ---
onMounted(async () => {
  // 0. Check User Auth
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    router.push('/')
    return
  }

  // 1. Verify Session & Ownership
  const { data: session, error } = await supabase
    .from('sessions')
    .select('*')
    .eq('id', sessionId)
    .single()

  if (error || !session) {
    console.error('Session Init Error:', error)
    alert('Session not found or access denied.')
    router.push('/dashboard')
    return
  }

  // 2. Strict Ownership Check
  if (session.owner_id !== user.id) {
    console.warn('Unauthorized access attempt to session:', sessionId)
    router.push('/dashboard')
    return
  }

  sessionName.value = session.name
  setupRealtime()
  // Ensure DB is in sync with actual files (auto-heal)
  await syncStorageToDb()
  fetchAssets()
})

const syncStorageToDb = async () => {
  // 1. List files in actual storage
  const { data: files, error } = await supabase.storage
    .from(bucketName)
    .list(`sessions/${sessionId}`, { limit: 100 })

  if (error) {
    console.error('Storage List Error:', error)
    return
  }

  if (!files || files.length === 0) return

  // 2. Get what DB thinks we have
  const { data: dbAssets } = await supabase
    .from('session_assets')
    .select('file_name')
    .eq('session_id', sessionId)

  const dbFileNames = new Set(dbAssets?.map(a => a.file_name) || [])

  // 3. Identify Orphans (In Storage but NOT in DB)
  // Filter out .emptyFolderPlaceholder and dotfiles
  const orphans = files.filter(f =>
    !dbFileNames.has(f.name) &&
    f.name !== '.emptyFolderPlaceholder' &&
    !f.name.startsWith('.')
  )

  if (orphans.length > 0) {
    console.log(`Found ${orphans.length} orphaned files. Syncing to DB...`)

    const toInsert = orphans.map(f => ({
      session_id: sessionId,
      file_name: f.name,
      storage_path: `sessions/${sessionId}/${f.name}`,
      is_revealed: false
    }))

    const { error: insertError } = await supabase
      .from('session_assets')
      .insert(toInsert)

    if (insertError) console.error('Sync Insert Error:', insertError)
  }
}

// --- Core Logic ---

const fetchAssets = async () => {
  const { data, error } = await supabase
    .from('session_assets')
    .select('*')
    .eq('session_id', sessionId)
    .neq('file_name', '.emptyFolderPlaceholder') // Filter out placeholder
    .order('created_at', { ascending: false })

  if (error) console.error('Fetch Error:', error)
  if (data) {
    // Extra client-side filter for strictness
    assets.value = data.filter(a => !a.file_name.startsWith('.'))
  }
}

// --- Upload Logic ---

const onFileChange = (e) => handleUploads(Array.from(e.target.files))
const onFileDrop = (e) => handleUploads(Array.from(e.dataTransfer.files))

const handleUploads = async (files) => {
  const imageFiles = files.filter(f => f.type.startsWith('image/'))
  if (imageFiles.length === 0) return

  isUploading.value = true

  for (let i = 0; i < imageFiles.length; i++) {
    const file = imageFiles[i]
    uploadStatus.value = `Uploading ${i + 1}/${imageFiles.length}`

    try {
      let compressedFile = file

      // 1. Compress (Skip for GIFs to preserve animation)
      if (!file.type.match(/gif/i)) {
        const options = { maxSizeMB: 1, maxWidthOrHeight: 1920, useWebWorker: true }
        try {
          compressedFile = await imageCompression(file, options)
        } catch (compError) {
          console.warn('Compression failed, using original:', compError)
        }
      }

      // 2. Upload Storage
      const safeName = `${Date.now()}_${file.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`
      const filePath = `sessions/${sessionId}/${safeName}`
      const { error: storageError } = await supabase.storage
        .from(bucketName)
        .upload(filePath, compressedFile)

      if (storageError) throw storageError

      // 3. Register DB
      const { error: dbError } = await supabase
        .from('session_assets')
        .insert({
          session_id: sessionId,
          file_name: safeName, // Store the FULL name so it matches storage
          storage_path: filePath,
          is_revealed: false
        })

      if (dbError) throw dbError

    } catch (e) {
      console.error('Upload Failed:', e)
      alert(`Failed to upload ${file.name}: ${e.message}`)
    }
  }

  isUploading.value = false
  uploadStatus.value = ''
  fetchAssets() // Refresh grid
}

// --- Actions ---

const renameAsset = async (asset) => {
  const newName = prompt('New name for this image:', asset.display_name || getDisplayName(asset.file_name))
  if (!newName || newName.trim() === '') return

  const { error } = await supabase
    .from('session_assets')
    .update({ display_name: newName })
    .eq('id', asset.id)

  if (error) {
    alert('Error renaming: ' + error.message)
  } else {
    asset.display_name = newName // Optimistic update
  }
}

const deleteAsset = async (asset) => {
  if (!confirm('Delete this image?')) return

  // 1. Delete DB
  const { error: dbError } = await supabase.from('session_assets').delete().eq('id', asset.id)
  
  if (dbError) {
    alert('Failed to delete asset from database: ' + dbError.message)
    return
  }

  // 2. Delete Storage
  const { error: storageError } = await supabase.storage.from(bucketName).remove([asset.storage_path])
  
  if (storageError) {
    console.error('Failed to delete file from storage:', storageError)
    // Optional: alert user, but the item is gone from the UI anyway
  }

  fetchAssets() 
}

const broadcastImage = async () => {
  if (!lightboxAsset.value) return
  const asset = lightboxAsset.value

  // Update DB
  await supabase.from('session_assets')
    .update({ is_revealed: true })
    .eq('id', asset.id)

  // Update Local State directly
  asset.is_revealed = true

  // Broadcast
  if (channel.value) {
    await channel.value.send({
      type: 'broadcast',
      event: 'show_image',
      payload: {
        imgName: asset.file_name,
        path: asset.storage_path,
        displayName: asset.display_name || getDisplayName(asset.file_name) // Send Display Name
      }
    })
  }
}

const hideImage = async () => {
  if (!lightboxAsset.value) return;
  const asset = lightboxAsset.value;

  // 1. Update DB (Persist hidden state)
  await supabase.from('session_assets')
    .update({ is_revealed: false })
    .eq('id', asset.id);

  // 2. Update Local State
  asset.is_revealed = false;

  // 3. Broadcast to Players/Stream
  if (channel.value) {
    await channel.value.send({
      type: 'broadcast',
      event: 'hide_image',
      payload: { imgName: asset.file_name }
    })
  }
}

const hideImageFromStream = async () => {
  if (channel.value) {
    await channel.value.send({
      type: 'broadcast',
      event: 'hide_image_stream',
      payload: {}
    })
    streamHiddenState.value = true
  }
}

const restoreStream = async () => {
  // Re-broadcast just to be sure, or specific show_stream event
  // Since stream view listens to show_image, we reuse broadcastImage but don't double update DB
  // Actually simpler: just call broadcastImage() -> it updates 'is_revealed' true (idempotent) and sends event
  await broadcastImage()
  streamHiddenState.value = false
}

const setupRealtime = () => {
  if (channel.value) supabase.removeChannel(channel.value)
  channel.value = supabase.channel(`session_${sessionId}`)
  channel.value.subscribe()
}

const endSession = async () => {
  if (!confirm('EXTREMELY DESTRUCTIVE ACTION:\n\nThis will delete the session and ALL IMAGES permanently from the server.\n\nAre you sure you want to end?')) {
    return
  }

  isUploading.value = true // Show spinner or similar
  uploadStatus.value = 'Deleting session data...'

  try {
    // 1. Clean Storage (List first, then remove)
    const { data: files } = await supabase.storage
      .from(bucketName)
      .list(`sessions/${sessionId}`, { limit: 1000 })

    if (files && files.length > 0) {
      const filesToRemove = files.map(f => `sessions/${sessionId}/${f.name}`)
      await supabase.storage.from(bucketName).remove(filesToRemove)
    }

    // 2. Delete Session (Cascade should handle assets, but let's be safe)
    // Delete assets first if cascade isn't set
    await supabase.from('session_assets').delete().eq('session_id', sessionId)

    // Delete session
    const { error } = await supabase.from('sessions').delete().eq('id', sessionId)

    if (error) throw error

    router.push('/dashboard')

  } catch (e) {
    console.error('Destruction Error', e)
    alert('Error deleting session: ' + e.message)
    isUploading.value = false
    uploadStatus.value = ''
  }
}

// --- Helpers ---

const getAssetUrl = (asset) => {
  const { data } = supabase.storage.from(bucketName).getPublicUrl(asset.storage_path)
  return data.publicUrl
}

const getCardClasses = (asset) => {
  if (asset.is_revealed) return 'ring-2 ring-green-500 shadow-[0_0_15px_rgba(34,197,94,0.3)]'
  return 'ring-slate-700 hover:ring-indigo-500'
}

const getDisplayName = (fullName) => {
  const parts = fullName.split('_')
  if (parts.length > 1 && !isNaN(parts[0])) {
    return parts.slice(1).join('_')
  }
  return fullName
}

const copyJoinLink = () => {
  const link = `${window.location.origin}/join/${sessionId}`
  navigator.clipboard.writeText(link)
  linkCopied.value = true
  setTimeout(() => linkCopied.value = false, 2000)
}

const toggleBlur = () => blurMode.value = !blurMode.value
const openLightbox = (asset) => {
  lightboxAsset.value = asset
  streamHiddenState.value = false // Reset validation
}
const closeLightbox = () => lightboxAsset.value = null

const gridClasses = computed(() => {
  if (viewMode.value === 'small') return 'grid-cols-4 sm:grid-cols-6 md:grid-cols-8'
  return 'grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5'
})
</script>
