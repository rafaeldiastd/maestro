<template>
  <div class="flex h-screen w-screen bg-lumina-bg text-lumina-text overflow-hidden">

    <!-- Icon Sidebar (Player Version) -->
    <IconSidebar :items="sidebarItems" :activeItem="activeSidebar" @select="handleSidebarSelect">
      <template #bottom>
        <Button variant="ghost" size="icon"
          class="h-11 w-11 rounded-lg text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
          @click="$router.push('/dashboard')">
          <ArrowLeft class="h-5 w-5" />
        </Button>
      </template>
    </IconSidebar>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col min-w-0 bg-lumina-bg ml-16 relative overflow-hidden">

      <!-- Connection Status (Absolute Top Right) -->
      <div
        class="absolute top-4 right-4 z-20 flex items-center gap-2 rounded-full border border-lumina-border bg-lumina-card/90 px-3 py-1.5 text-xs backdrop-blur-md shadow-sm transition-opacity hover:opacity-100"
        :class="isConnected ? 'opacity-50 hover:opacity-100' : 'text-yellow-500 border-yellow-900/30 bg-yellow-950/30'">
        <div v-if="isConnected" class="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]"></div>
        <div v-else class="h-2 w-2 rounded-full bg-yellow-500 animate-pulse"></div>
        <span class="font-medium">{{ isConnected ? 'Conectado' : 'Conectando...' }}</span>
      </div>

      <!-- Gallery / Map Area -->
      <div class="flex-1 overflow-y-auto p-4 md:p-8">
        <div v-if="images.length === 0" class="flex flex-col items-center justify-center h-full">
          <div class="p-6 rounded-full bg-zinc-900/50 mb-4 border border-lumina-border">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"
              class="text-zinc-600">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
              <circle cx="8.5" cy="8.5" r="1.5"></circle>
              <polyline points="21 15 16 10 5 21"></polyline>
            </svg>
          </div>
          <p class="text-sm font-medium text-zinc-400">Nada por aqui ainda</p>
          <p class="text-xs text-zinc-600 mt-1">Aguarde o Mestre revelar imagens...</p>
        </div>

        <div v-else
          class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 max-w-7xl mx-auto">
          <div v-for="img in images" :key="img.name"
            class="group relative aspect-square cursor-pointer overflow-hidden rounded-xl bg-lumina-card ring-1 ring-lumina-border transition-all hover:ring-lumina-detail hover:shadow-lg"
            @click="openLightbox(img)">

            <img :src="img.url" loading="lazy"
              class="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105">

            <div
              class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent p-4 opacity-0 transition-opacity duration-300 group-hover:opacity-100 flex items-end">
              <p class="truncate text-xs font-medium text-zinc-100 w-full">
                {{ img.displayName }}
              </p>
            </div>
          </div>
        </div>
      </div>

    </main>

    <!-- Sidebars -->

    <!-- Character Selection Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-80 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'characters' ? 'translate-x-0' : '-translate-x-full'">
      <CharacterSelectionSidebar v-if="currentUserId && sessionId" :session-id="sessionId" :user-id="currentUserId"
        @close="activeSidebar = null" @select="openCharacterSheet" />
    </div>

    <!-- Notes Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-80 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'notes' ? 'translate-x-0' : '-translate-x-full'">
      <!-- Reusing Master's notes sidebar for now, but stripped down logic might be needed if RLS restricts too much. 
           Assuming players can see their own notes/folders. -->
      <NotesSidebar :is-open="true" :folders="noteFolders" :notes="notes" @close="activeSidebar = null"
        @create-note="createNote" @create-folder="createNoteFolder" @delete-note="deleteNote"
        @delete-folder="deleteNoteFolder" @open-note="openNote" />
    </div>

    <!-- Note Editor (Overlay) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-50 w-[600px] bg-lumina-card border-r border-lumina-border shadow-2xl transition-transform duration-300"
      :class="(activeNote && activeSidebar === 'notes') ? 'translate-x-0' : '-translate-x-full'">
      <NoteEditor v-if="activeNote" :note="activeNote" @update="updateNote" @close="activeNote = null" />
    </div>

    <!-- Chat Sidebar (Right) -->
    <ChatSidebar v-if="currentUserId" :campaign-id="sessionId" :current-user-id="currentUserId" :is-owner="false"
      :is-open="isChatOpen" @toggle="isChatOpen = !isChatOpen" />

    <!-- Character Sheet Overlay -->
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4 md:p-8"
      v-if="activeCharacter">
      <div
        class="w-full max-w-5xl h-full max-h-[90vh] rounded-xl overflow-hidden shadow-2xl animate-in fade-in zoom-in-95 duration-200">
        <CharacterSheet :character="activeCharacter" :template="campaignTemplate" @close="activeCharacter = null"
          @update="handleCharacterUpdate" @roll="handleRoll" />
      </div>
    </div>

    <!-- Lightbox -->
    <Lightbox :isOpen="!!lightboxAsset" :imageUrl="lightboxAsset ? lightboxAsset.url : ''"
      :title="lightboxAsset ? lightboxAsset.displayName : ''" :showBroadcast="false" @close="closeLightbox" />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { useStorage } from '@/composables/useStorage'
import { Map, User, FileText, Settings, MessageSquare, ArrowLeft } from 'lucide-vue-next'

// Components
import IconSidebar from '@/components/shared/IconSidebar.vue'
import ChatSidebar from '@/features/chat/components/ChatSidebar.vue'
import Lightbox from '@/components/shared/Lightbox.vue'
import { Button } from '@/components/ui/button'
import CharacterSelectionSidebar from '../components/CharacterSelectionSidebar.vue'
import CharacterSheet from '../components/CharacterSheet.vue'
import NotesSidebar from '@/features/notes/components/NotesSidebar.vue'
import NoteEditor from '@/features/notes/components/NoteEditor.vue'

const route = useRoute()
const router = useRouter()
const sessionId = route.params.id

const { storage, setConfig } = useStorage()

// User State
const currentUserId = ref(null)
const isConnected = ref(false)

// UI State
const activeSidebar = ref(null)
const isChatOpen = ref(true)
const lightboxAsset = ref(null)

// Content State
const images = ref([])
const notes = ref([])
const noteFolders = ref([])
const activeNote = ref(null)

// Sidebar Items
const sidebarItems = computed(() => [
  { id: 'characters', icon: User, label: 'Personagens', active: activeSidebar.value === 'characters' },
  { id: 'map', icon: Map, label: 'Galeria', active: activeSidebar.value === 'map' }, // Default View
  { id: 'notes', icon: FileText, label: 'Notas', active: activeSidebar.value === 'notes' },
  { id: 'chat', icon: MessageSquare, label: 'Chat', active: isChatOpen.value },
  { id: 'settings', icon: Settings, label: 'Configurações', active: activeSidebar.value === 'settings' },
])

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (user) {
    currentUserId.value = user.id
  }

  // Init Storage
  const { data: session } = await supabase.from('sessions').select('storage_provider, storage_config').eq('id', sessionId).single()
  if (session) {
    setConfig(session.storage_provider || 'supabase', session.storage_config || {})
  }

  loadHistory()
  setupRealtime()
  // fetchNotes() - Implement note fetching for player (add RLS check in mind)
})

const handleSidebarSelect = (id) => {
  if (id === 'chat') {
    isChatOpen.value = !isChatOpen.value
    return
  }
  if (activeSidebar.value === id) {
    activeSidebar.value = null
  } else {
    activeSidebar.value = id
  }
}

// --- Image/Map Logic (Simplified from original) ---
const loadHistory = async () => {
  try {
    const { data } = await supabase.from('session_assets')
      .select('file_name, storage_path, display_name')
      .eq('session_id', sessionId).eq('is_revealed', true)
      .order('created_at', { ascending: true })

    if (data) {
      data.forEach(asset => addImage(asset.file_name, asset.storage_path, false, asset.display_name))
    }
  } catch (e) { console.error(e) }
}

const setupRealtime = () => {
  supabase.channel(`session_${sessionId}`)
    .on('broadcast', { event: 'show_image' }, ({ payload }) => {
      const path = payload.path || `sessions/${sessionId}/${payload.imgName}`
      addImage(payload.imgName, path, true, payload.displayName)
    })
    .on('broadcast', { event: 'hide_image' }, ({ payload }) => {
      removeImage(payload.imgName)
    })
    .subscribe(status => {
      if (status === 'SUBSCRIBED') isConnected.value = true
    })
}

const addImage = (name, path, open, displayName) => {
  const existing = images.value.find(i => i.name === name)
  if (existing) {
    if (open) openLightbox(existing)
    return
  }
  const url = storage.value.getUrl(path)
  const imgObj = { name, displayName: displayName || name, url }
  images.value.push(imgObj)
  if (open) openLightbox(imgObj)
}

const removeImage = (name) => {
  images.value = images.value.filter(i => i.name !== name)
  if (lightboxAsset.value?.name === name) closeLightbox()
}

const openLightbox = (img) => lightboxAsset.value = img
const closeLightbox = () => lightboxAsset.value = null

// --- Character Logic ---
const openCharacterSheet = (char) => {
  // TODO: Implement Sheet View Modal/Overlay
  console.log('Open Sheet', char)
  // For now, we can just log. Next step would be to reuse NPCSheet or create CharacterSheet.vue
  alert(`Abrir ficha de ${char.name} (Em desenvolvimento)`)
}

// --- Notes Logic (Placeholder) ---
const createNote = () => { }
const createNoteFolder = () => { }
const deleteNote = () => { }
const deleteNoteFolder = () => { }
const openNote = (note) => { activeNote.value = note }
const updateNote = () => { }

</script>
