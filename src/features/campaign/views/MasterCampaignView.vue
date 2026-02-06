<template>
  <div class="flex h-screen w-screen bg-lumina-bg text-lumina-text overflow-hidden">

    <!-- Icon Sidebar -->
    <IconSidebar :items="sidebarItems" :activeItem="activeSidebar" @select="handleSidebarSelect">

      <template #bottom>
        <Button variant="ghost" size="icon"
          class="h-11 w-11 rounded-lg text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
          @click="$router.push('/dashboard')">
          <ArrowLeft class="h-5 w-5" />
        </Button>
      </template>
    </IconSidebar>

    <!-- Main Content (Map Canvas) -->
    <main class="flex-1 flex flex-col min-w-0 bg-lumina-bg ml-16 relative overflow-hidden">
      <!-- Map Toolbar (when map is active`) -->
      <MapToolbar v-if="selectedMap" :show-grid="showGrid" :current-layer="currentLayer" :current-tool="currentTool"
        :zoom="currentZoom" @zoom-in="handleZoom(1)" @zoom-out="handleZoom(-1)" @toggle-grid="showGrid = !showGrid"
        @open-settings="openGridSettings" @change-layer="currentLayer = $event" @select-tool="currentTool = $event" />

      <!-- Inline Map Canvas -->
      <div class="flex-1 relative">
        <MapCanvasInline v-if="selectedMap" ref="canvasRef" :map="selectedMap" :show-grid="showGrid"
          :current-layer="currentLayer" />

        <!-- Empty State -->
        <div v-else class="flex items-center justify-center h-full text-lumina-text-muted">
          <div class="text-center">
            <p class="text-lg font-inknut mb-2">Nenhum Mapa Ativo</p>
            <p class="text-sm">Clique em "Mapas" para começar</p>
          </div>
        </div>
      </div>
    </main>

    <!-- Maps Sidebar (Fixed Left) -->
    <div class="fixed left-16 top-0 bottom-0 z-30 w-80 bg-card border-r border-border transition-transform duration-300"
      :class="activeSidebar === 'maps' ? 'translate-x-0' : '-translate-x-full'">
      <div class="h-full flex flex-col">
        <!-- Header -->
        <div class="h-14 shrink-0 border-b border-border flex items-center justify-between px-4 bg-card">
          <div class="flex items-center gap-2">
            <Map class="h-4 w-4 text-primary" />
            <span class="text-sm font-bold text-foreground font-serif tracking-wide">Mapas</span>
          </div>
          <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground hover:bg-muted"
            @click="activeSidebar = null">
            <X class="h-4 w-4" />
          </Button>
        </div>

        <!-- Create Button -->
        <div class="p-4 border-b border-lumina-border shrink-0">
          <Button @click="modals.createMap.open = true" size="sm" class="w-full gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2">
              <path d="M12 5v14M5 12h14" />
            </svg>
            Criar Novo Mapa
          </Button>
        </div>

        <!-- Map List -->
        <div class="flex-1 overflow-y-auto p-4 space-y-2">
          <div v-for="map in maps" :key="map.id"
            class="group relative bg-lumina-bg border border-lumina-border rounded-lg overflow-hidden hover:border-lumina-detail transition-all cursor-pointer"
            @click="handleSelectMap(map)">
            <div class="aspect-video bg-lumina-bg/50 relative">
              <img v-if="map.background_url" :src="map.background_url" class="w-full h-full object-cover"
                alt="Map preview" />
              <div v-else class="w-full h-full flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="1" class="text-lumina-text-muted">
                  <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
                </svg>
              </div>

              <div v-if="map.is_active"
                class="absolute top-2 right-2 bg-green-600 text-white text-xs font-bold px-2 py-1 rounded flex items-center gap-1">
                <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2">
                  <path d="M20 6 9 17l-5-5" />
                </svg>
                Visível
              </div>
            </div>

            <div class="p-3">
              <h3 class="font-bold text-sm text-lumina-text truncate">{{ map.name }}</h3>
              <p class="text-xs text-lumina-text-muted mt-1">{{ map.width }}×{{ map.height }}px</p>
            </div>

            <div class="absolute top-2 left-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
              <Button @click.stop="toggleMapActive(map)" variant="ghost" size="sm"
                class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-lumina-bg"
                :title="map.is_active ? 'Esconder dos Jogadores' : 'Mostrar aos Jogadores'">
                <svg v-if="!map.is_active" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"
                  fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                  <circle cx="12" cy="12" r="3" />
                </svg>
                <svg v-else xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2">
                  <path
                    d="M9.88 9.88a3 3 0 1 0 4.24 4.24M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24M1 1l22 22M2.42 2.42l2.38 2.38" />
                </svg>
              </Button>

              <Button @click.stop="deleteMap(map)" variant="ghost" size="sm"
                class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-red-500/20 text-red-400" title="Excluir">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2">
                  <path d="M3 6h18M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
                </svg>
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Map Sidebar (Overlay) -->
    <Transition name="slide">
      <MapCreateSidebar v-if="modals.createMap.open" ref="createSidebarRef" @close="modals.createMap.open = false"
        @save="handleSaveNewMap" @pick-image="handlePickImageForCreate" />
    </Transition>

    <!-- Grid Settings Sidebar (from toolbar) -->
    <Transition name="slide">
      <MapSettingsSidebar v-if="modals.mapSettings.open && selectedMap" :map="selectedMap"
        @close="handleCancelGridSettings" @cancel="handleCancelGridSettings" @preview="handlePreviewGridSettings"
        @save="handleSaveGridSettings" />
    </Transition>

    <!-- Asset Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-96 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'assets' ? 'translate-x-0' : '-translate-x-full'">
      <div class="h-full flex flex-col">
        <!-- Header Standard -->
        <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-lumina-bg/80">
          <div class="flex items-center gap-2">
            <ImageIcon class="h-4 w-4 text-lumina-detail" />
            <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Gerenciador de Arquivos</span>
          </div>
          <Button variant="ghost" size="icon"
            class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
            @click="activeSidebar = null">
            <X class="h-4 w-4" />
          </Button>
        </div>

        <div class="flex-1 overflow-hidden">
          <AssetManagerModal :assets="assets" :folders="folders" :current-folder-id="currentFolderId"
            :view-mode="viewMode" :blur-mode="blurMode" :is-uploading="isUploading" :get-asset-url="getAssetUrl"
            :is-picker="isPickingImage"
            @create-folder="createFolder" @open-folder="openFolder" @delete-folder="deleteFolder"
            @move-asset="moveAssetToFolder" @file-upload="onFileChange" @file-drop="onFileDrop"
            @open-lightbox="openLightbox" @rename="renameAsset" @delete="deleteAsset"
            @update:viewMode="viewMode = $event" @toggle-blur="toggleBlur" @pick="handleAssetPick" />
        </div>
      </div>
    </div>

    <!-- Notes Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-80 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'notes' ? 'translate-x-0' : '-translate-x-full'">
      <div class="h-full flex flex-col">
        <NotesSidebar :is-open="true" :folders="noteFolders" :notes="notes" @close="activeSidebar = null"
          @create-note="createNote" @create-folder="createNoteFolder" @delete-note="deleteNote"
          @delete-folder="deleteNoteFolder" @open-note="openNote" @move-item="moveNoteItem" />
      </div>
    </div>

    <!-- Bestiary Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-80 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'bestiary' ? 'translate-x-0' : '-translate-x-full'">
      <div class="h-full flex flex-col relative bg-lumina-card">
        <BestiarySidebar :npcs="npcs" @create="openNpcModal(null)" @edit="openNpcModal" @delete="deleteNpc"
          @select="openNpcSheet" @close="activeSidebar = null" />
      </div>
    </div>

    <!-- Initiative Sidebar (Fixed Left) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-80 bg-lumina-card border-r border-lumina-border transition-transform duration-300"
      :class="activeSidebar === 'initiative' ? 'translate-x-0' : '-translate-x-full'">
      <InitiativeSidebar :participants="initiativeParticipants" :round="initiativeRound"
        :active-participant-id="initiativeActiveIndex" v-model:is-capturing="isCapturingInitiative"
        @update:participants="saveInitiative" @next-turn="handleInitiativeNext" @clear="handleInitiativeClear"
        @close="activeSidebar = null" />
    </div>

    <!-- NPC Modal -->
    <NPCModal v-model:open="showNpcModal" :system="campaignSystem" :npc="activeNpc" @save="handleSaveNpc"
      @open-note="handleOpenNpcNote" />

    <!-- NPC Sheet (Preview) -->
    <div
      class="fixed left-96 top-0 bottom-0 z-30 w-[400px] bg-lumina-card/95 backdrop-blur-xl transition-all duration-300 shadow-2xl border-r border-lumina-border"
      :class="activeNpcSheet ? 'translate-x-0 opacity-100' : '-translate-x-[120%] opacity-0 pointer-events-none'">
      <NPCSheet v-if="activeNpcSheet" :npc="activeNpcSheet" :system="campaignSystem" @close="activeNpcSheet = null"
        @edit="handleEditNpcFromSheet" @open-note="handleOpenNpcNoteFromSheet" @update-hp="handleSaveNpc"
        @save="handleSaveNpc" @roll="handleNpcAbilityRoll" @chat="handleNpcAbilityChat" />
    </div>

    <!-- Note Editor Panel (Fixed Lateral) -->
    <div
      class="fixed left-16 top-0 bottom-0 z-40 w-[600px] bg-lumina-card border-r border-lumina-border shadow-2xl transition-transform duration-300"
      :class="(activeNote && activeSidebar === 'notes') ? 'translate-x-0' : '-translate-x-full'">
      <NoteEditor v-if="activeNote" ref="noteEditorRef" :note="activeNote" @update="updateNote"
        @pick-image="handlePickImage" @close="activeNote = null" />
    </div>

    <!-- Lightbox (Global Overlay) -->
    <Lightbox :isOpen="!!lightboxAsset" :imageUrl="lightboxAsset ? getAssetUrl(lightboxAsset) : ''"
      :title="lightboxAsset?.display_name || lightboxAsset?.file_name" :showBroadcast="true"
      :isRevealed="lightboxAsset?.is_revealed" :isStreamHidden="streamHiddenState" @close="closeLightbox"
      @broadcast="broadcastImage" @hide="hideImage" @update:title="renameAsset(lightboxAsset, $event)"
      @hide-stream="hideImageFromStream" @show-stream="restoreStream" />

    <!-- Realtime Chat Sidebar -->
    <ChatSidebar v-if="currentUserId" :campaign-id="sessionId" :current-user-id="currentUserId" :is-owner="true"
      :is-open="isChatOpen" :active-context="activeNpcSheet" :is-capturing="isCapturingInitiative"
      @toggle="isChatOpen = !isChatOpen" @add-initiative="handleManualInitiativeAdd" />

  </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { storeToRefs } from 'pinia'
import { useStorage } from '@/composables/useStorage'
import { useCampaignInvites } from '@/composables/useCampaignInvites'
import { useChatStore } from '@/stores/chat'
import { useInitiativeStore } from '@/stores/initiative'
import { useDiceRoll } from '@/composables/useDiceRoll'
import imageCompression from 'browser-image-compression'
import { Image as ImageIcon, Settings, Map, ArrowLeft, X, FileText, MessageSquare, Skull, Sword } from 'lucide-vue-next'

// Components
import IconSidebar from '@/components/shared/IconSidebar.vue'
import DraggableModal from '@/components/shared/DraggableModal.vue'
import AssetManagerModal from '../components/modals/AssetManagerModal.vue'
import BestiarySidebar from '../components/BestiarySidebar.vue'
import InitiativeSidebar from '../components/InitiativeSidebar.vue'
import NPCModal from '../components/modals/NPCModal.vue'
import NPCSheet from '../components/NPCSheet.vue'
import NotesSidebar from '@/features/notes/components/NotesSidebar.vue'
import NoteEditor from '@/features/notes/components/NoteEditor.vue'
import MapCanvasInline from '@/features/maps/components/MapCanvasInline.vue'
import MapToolbar from '@/features/maps/components/MapToolbar.vue'
import MapCreateSidebar from '@/features/maps/components/MapCreateSidebar.vue'
import MapSettingsSidebar from '@/features/maps/components/MapSettingsSidebar.vue'
import Lightbox from '@/components/shared/Lightbox.vue'
import ChatSidebar from '@/features/chat/components/ChatSidebar.vue'
import { Button } from '@/components/ui/button'

// --- State ---
const route = useRoute()
const router = useRouter()
const sessionId = route.params.id

const sessionName = ref('')
const sessionCreatedAt = ref('')
const campaignSystem = ref('generic') // Default to generic
const storageConfig = ref({})
const assets = ref([])
const viewMode = ref('grid')
const blurMode = ref(false)
const lightboxAsset = ref(null)
const streamHiddenState = ref(false)
const connectedPlayers = ref([])
const currentUserId = ref(null)
const isChatOpen = ref(true)
const unreadMessages = ref(0) // Added for chat badge

const { storage, providerType, setConfig } = useStorage()
const chatStore = useChatStore()
const { sendMessage } = chatStore
const { roll } = useDiceRoll()
const channel = ref(null)

onMounted(() => {
  fetchInitiative(sessionId)
  fetchMaps()
  fetchNpcs()
})

// Upload State
const isUploading = ref(false)
const uploadStatus = ref('')

// --- Notes State ---
const notes = ref([])
const noteFolders = ref([])
const activeNote = ref(null)
const noteEditorRef = ref(null) // [NEW] Ref for NoteEditor

// --- Bestiary State ---
const npcs = ref([])
const showNpcModal = ref(false)
const activeNpc = ref(null)
const activeNpcSheet = ref(null)

// --- Initiative State (Pinia) ---
const initiativeStore = useInitiativeStore()
const {
  participants: initiativeParticipants,
  currentRound: initiativeRound,
  activeIndex: initiativeActiveIndex,
  isCapturing: isCapturingInitiative
} = storeToRefs(initiativeStore)

const {
  addParticipant,
  updateParticipantsList,
  nextTurn,
  clearInitiative,
  fetchInitiative
} = initiativeStore

const { messages } = storeToRefs(chatStore) // Need messages to watch

watch(messages, (newMessages) => {
  // If not capturing and not explicit, ignore?
  // Watcher logic refactored to check context.

  if (!newMessages || newMessages.length === 0) return
  const lastMsg = newMessages[newMessages.length - 1]

  try {
    if (typeof lastMsg.content === 'string' && lastMsg.content.trim().startsWith('{')) {
      const data = JSON.parse(lastMsg.content)

      // Check for initiative context
      if (data && (data.context === 'initiative' || data.type === 'card')) {

        // 1. Explicit Initiative (from /init) - ALWAYS capture
        if (data.context === 'initiative') {
          if (!isCapturingInitiative.value) return // ONLY capture if switch is ON

          const rawName = data.name || 'Desconhecido'
          const name = rawName.split(' - ')[0]
          const total = data.total || 0

          addParticipant({
            id: crypto.randomUUID(),
            name: name,
            total: total,
            type: 'player'
          }, sessionId)
          return
        }
      }
    }
  } catch (e) {
    console.error('Initiative Watcher Error:', e)
  }
}, { deep: true })

const saveInitiative = (newParticipants) => {
  // Logic from sidebar update
  if (Array.isArray(newParticipants)) {
    updateParticipantsList(newParticipants, sessionId)
  }
}

const handleInitiativeNext = () => {
  nextTurn(sessionId)
}

const handleInitiativeClear = () => {
  if (confirm('Limpar toda a iniciativa?')) {
    clearInitiative(sessionId)
  }
}

const handleManualInitiativeAdd = ({ name, total }) => {
  // Check duplicates in Singleton
  const existing = initiativeParticipants.value.find(p => p.name === name)
  if (existing) {
    if (confirm(`${name} já está na iniciativa (${existing.total}). Atualizar para ${total}?`)) {
      addParticipant({ id: existing.id, name, total, type: existing.type }, sessionId)
    }
  } else {
    addParticipant({
      id: crypto.randomUUID(),
      name,
      total,
      type: 'player'
    }, sessionId)
    // Removed broken modal usage. Sidebar handles its own visibility via watchers or activeSidebar if simplified.
    // Ideally, just adding it automatically opens the sidebar if we want feedback.
    activeSidebar.value = 'initiative'
  }
}


// --- Picker State ---
const isPickingImage = ref(false)
const pickerCallback = ref(null) // [NEW] Store callback for arbitrary picking

// --- Maps State ---
const maps = ref([])
const selectedMapId = ref(null) // Map currently being viewed by master
const selectedMap = computed(() => maps.value.find(m => m.id === selectedMapId.value))
const activeGameMap = computed(() => maps.value.find(m => m.is_active)) // Map visible to players
const showGrid = ref(true)
const currentLayer = ref('map')
const currentTool = ref('move')
const currentZoom = ref(1)
const canvasRef = ref(null)
const createSidebarRef = ref(null)

// Sidebar Management
const activeSidebar = ref(null)

const modals = reactive({
  createMap: { open: false },
  mapSettings: { open: false }
})

// Sidebar Items
const sidebarItems = computed(() => [
  {
    id: 'maps',
    icon: Map,
    label: 'Mapas',
    badge: 0,
    active: activeSidebar.value === 'maps'
  },
  {
    id: 'assets',
    icon: ImageIcon,
    label: 'Arquivos',
    badge: assets.value.length,
    active: activeSidebar.value === 'assets'
  },
  {
    id: 'bestiary',
    icon: Skull,
    label: 'Bestiário',
    badge: npcs.value.length,
    active: activeSidebar.value === 'bestiary'
  },
  {
    id: 'initiative',
    icon: Sword,
    label: 'Iniciativa',
    badge: initiativeParticipants.value.length,
    active: activeSidebar.value === 'initiative'
  },
  {
    id: 'notes',
    icon: FileText,
    label: 'Notas',
    badge: notes.value.length,
    active: activeSidebar.value === 'notes'
  },
  {
    id: 'settings',
    icon: Settings,
    label: 'Configurações',
    badge: 0
  },
  {
    id: 'chat',
    icon: MessageSquare,
    label: 'Chat',
    badge: unreadMessages.value > 0 ? unreadMessages.value : 0,
    active: isChatOpen.value
  }
])

// --- Management ---
const handleSidebarSelect = (itemId) => {
  // Navigate to settings page
  if (itemId === 'settings') {
    router.push(`/campaign/${sessionId}/settings`)
    return
  }

  // Open chat toggle
  if (itemId === 'chat') {
    isChatOpen.value = !isChatOpen.value
    return
  }

  // Toggle Sidebars
  // Toggle Sidebars
  if (activeSidebar.value === itemId) {
    activeSidebar.value = null
  } else {
    activeSidebar.value = itemId
  }
  
  // Close picker mode if switching away from assets
  if (itemId !== 'assets') {
    isPickingImage.value = false
    pickerCallback.value = null
  }

  // Close details when switching away
  if (activeSidebar.value !== 'notes') activeNote.value = null
  if (activeSidebar.value !== 'bestiary') activeNpcSheet.value = null
}

// ... (Existing Close/Etc) ...

// --- Map Functions ---
const fetchMaps = async () => {
  const { data } = await supabase.from('campaign_maps').select('*').eq('session_id', sessionId).order('created_at', { ascending: false })
  if (data) {
    maps.value = data
    // Default to active map if available
    const active = data.find(m => m.is_active)
    if (active) {
      selectedMapId.value = active.id
    }
  }
}

// ... (Map Create/Select/Delete etc - Keeping mostly same logic, just showing updates around it)

const createMap = async () => {
  const { data } = await supabase.from('campaign_maps').insert({
    session_id: sessionId,
    name: 'Novo Mapa',
    width: 800,
    height: 600,
    grid_cols: 20,
    grid_rows: 15,
    grid_cell_width: 50,
    grid_cell_height: 50,
    grid_color: '#ffffff',
    grid_opacity: 0.3,
    grid_offset_top: 0,
    grid_offset_bottom: 0,
    grid_offset_left: 0,
    grid_offset_right: 0,
    grid_line_width: 1
  }).select().single()

  if (data) {
    maps.value.unshift(data)
    selectMap(data)
  }
}

const selectMap = (map) => {
  selectedMapId.value = map.id
}

const handleSelectMap = (map) => {
  selectMap(map)
  activeSidebar.value = null
}

const handlePickImageForCreate = () => {
  isPickingImage.value = true
  pickerCallback.value = (url) => {
    if (createSidebarRef.value && url) {
      createSidebarRef.value.setBackgroundUrl(url)
    }
    // Don't clear callback yet, let the closer handle it or simple reset
    activeSidebar.value = null // Close asset sidebar after picking
    pickerCallback.value = null
    isPickingImage.value = false
  }
  
  activeSidebar.value = 'assets' // Open Sidebar
  // Removed broken modals.assets.open = true
}

const handleAssetPick = (asset) => {
    if (pickerCallback.value && asset) {
        pickerCallback.value(getAssetUrl(asset))
    }
}

const handleSaveNewMap = async (mapData) => {
  const { data } = await supabase.from('campaign_maps').insert({
    session_id: sessionId,
    ...mapData
  }).select().single()

  if (data) {
    maps.value.unshift(data)
    if (data.is_active) {
      // Deactivate others
      await supabase.from('campaign_maps').update({ is_active: false }).eq('session_id', sessionId).neq('id', data.id)
      maps.value.forEach(m => {
        if (m.id !== data.id) m.is_active = false
      })
    }
    selectMap(data)
    modals.createMap.open = false
    activeSidebar.value = null
  }
}

const originalMapSettings = ref(null)

const openGridSettings = () => {
  if (!selectedMap.value) return
  // Snapshot current settings
  originalMapSettings.value = { ...selectedMap.value }
  modals.mapSettings.open = true
}

const handlePreviewGridSettings = (settings) => {
  if (!selectedMap.value) return
  // Update local state immediately for preview
  const updatedMap = { ...selectedMap.value, ...settings }
  const idx = maps.value.findIndex(m => m.id === updatedMap.id)
  if (idx !== -1) maps.value[idx] = updatedMap
}

const handleCancelGridSettings = () => {
  if (!selectedMap.value || !originalMapSettings.value) return
  // Revert to snapshot
  const idx = maps.value.findIndex(m => m.id === selectedMap.value.id)
  if (idx !== -1) maps.value[idx] = { ...originalMapSettings.value }

  modals.mapSettings.open = false
  originalMapSettings.value = null
}

const handleSaveGridSettings = async (settings) => {
  if (!selectedMap.value) return

  // Update local state (in case preview didn't run recently)
  const updatedMap = { ...selectedMap.value, ...settings }
  const idx = maps.value.findIndex(m => m.id === updatedMap.id)
  if (idx !== -1) maps.value[idx] = updatedMap

  // Persist to DB
  await supabase.from('campaign_maps').update(settings).eq('id', selectedMap.value.id)

  modals.mapSettings.open = false
  originalMapSettings.value = null
}

const deleteMap = async (map) => {
  if (!confirm(`Excluir "${map.name}"?`)) return
  await supabase.from('campaign_maps').delete().eq('id', map.id)
  maps.value = maps.value.filter(m => m.id !== map.id)
  if (selectedMapId.value === map.id) selectedMapId.value = null
}

const toggleMapActive = async (map) => {
  // Deactivate all others
  await supabase.from('campaign_maps').update({ is_active: false }).eq('session_id', sessionId).neq('id', map.id)

  // Toggle this one
  const newState = !map.is_active
  await supabase.from('campaign_maps').update({ is_active: newState }).eq('id', map.id)

  // Update local state
  maps.value.forEach(m => {
    if (m.id === map.id) m.is_active = newState
    else m.is_active = false
  })
}


const handleZoom = (direction) => {
  if (!canvasRef.value) return
  if (direction > 0) {
    canvasRef.value.zoomIn()
    currentZoom.value = canvasRef.value.getZoom()
  } else {
    canvasRef.value.zoomOut()
    currentZoom.value = canvasRef.value.getZoom()
  }
}

const closeModal = (modalId) => {
  if (modals[modalId]) {
    modals[modalId].open = false

    // Cascade Close logic
    if (modalId === 'bestiary') activeNpcSheet.value = null
    if (modalId === 'notes') activeNote.value = null
  }
}

const bringToFront = (modalId) => {
  // Not needed for fixed sidebars anymore, utilizing z-index in CSS
}

// --- Bestiary Functions ---
const openNpcSheet = (npc) => {
  activeNpcSheet.value = npc
  if (modals.notes.open) modals.notes.open = false
}

const handleEditNpcFromSheet = (npc) => {
  activeNpcSheet.value = null
  openNpcModal(npc)
}

const handleOpenNpcNoteFromSheet = (npc) => {
  handleOpenNpcNote(npc)
  activeNpcSheet.value = null
}


const fetchNpcs = async () => {
  // Check if table exists (or just try filtering)
  // We assume table 'campaign_npcs' exists with columns: id, session_id, name, hp, ac, challenge_rating, stats (jsonb), type (dnd5e/etc)
  const { data, error } = await supabase
    .from('campaign_npcs')
    .select('*')
    .eq('session_id', sessionId)
    .order('name', { ascending: true })

  if (!error && data) {
    npcs.value = data
  } else {
    // Fallback or just empty
    // console.warn('Não foi possível buscar NPCs. A tabela pode não existir ainda.')
  }
}

const openNpcModal = (npc) => {
  activeNpc.value = npc
  showNpcModal.value = true
}

const handleSaveNpc = async (npcData) => {
  // Remove UI-only fields
  const { note_tag, ...payload } = npcData

  if (activeNpc.value && activeNpc.value.id) {
    // Update
    const { data, error } = await supabase
      .from('campaign_npcs')
      .update(payload)
      .eq('id', activeNpc.value.id)
      .select().single()

    if (data) {
      const idx = npcs.value.findIndex(n => n.id === data.id)
      if (idx !== -1) npcs.value[idx] = data
    }
  } else {
    // Create
    const { data, error } = await supabase
      .from('campaign_npcs')
      .insert({
        ...payload,
        session_id: sessionId,
        system: campaignSystem.value
      })
      .select().single()

    if (data) {
      npcs.value.push(data)
    }
  }
}

const deleteNpc = async (npc) => {
  if (!confirm(`Excluir ${npc.name}?`)) return
  const { error } = await supabase.from('campaign_npcs').delete().eq('id', npc.id)
  if (!error) {
    npcs.value = npcs.value.filter(n => n.id !== npc.id)
  }
}

const handleOpenNpcNote = async (npc, initialTag) => {
  // 1. Check if note already exists
  if (npc.note_id) {
    const existingNote = notes.value.find(n => n.id === npc.note_id)
    if (existingNote) {
      openNote(existingNote)
      openNote(existingNote)
      showNpcModal.value = false // Focus Mode: Close NPC Modal
      activeSidebar.value = 'notes' // Switch sidebar to notes
      return
      return
    }
  }

  // 2. Create new note if not exists
  const { data: newNote, error } = await supabase.from('campaign_notes').insert({
    session_id: sessionId,
    title: npc.name || 'Nota de NPC',
    content: `Anotações para ${npc.name}\n\n`,
    tags: initialTag ? [initialTag] : []
  }).select().single()

  if (newNote) {
    notes.value.push(newNote)

    // 3. Link note to NPC
    const { data: updatedNpc } = await supabase
      .from('campaign_npcs')
      .update({ note_id: newNote.id })
      .eq('id', npc.id)
      .select().single()

    if (updatedNpc) {
      // Update local state
      const idx = npcs.value.findIndex(n => n.id === npc.id)
      if (idx !== -1) npcs.value[idx] = updatedNpc
      activeNpc.value = updatedNpc
    }

    // 4. Open Note & Focus
    openNote(newNote)
    showNpcModal.value = false
    showNpcModal.value = false
    activeSidebar.value = 'notes' // Switch to notes sidebar checking undefined modals logic removed
  }
}

const handleNpcAbilityChat = async (ability) => {
  if (!ability) return

  // Guess Context
  let context = 'ability'
  const lowerDesc = (ability.description || '').toLowerCase()

  if (lowerDesc.includes('spell') || ability.name.includes('Spell') || lowerDesc.includes('magic')) context = 'spell'
  else if (lowerDesc.includes('weapon') || lowerDesc.includes('attack') || lowerDesc.includes('hit')) context = 'attack'
  else if (lowerDesc.includes('action')) context = 'feature'

  const cardData = {
    type: 'card',
    subtype: context,
    title: ability.name,
    description: ability.description,
    properties: ability.effect ? { 'Effect': ability.effect } : {}
  }

  await sendMessage(sessionId, JSON.stringify(cardData))
}

// Helper to resolve variables
const calculateModifier = (val) => Math.floor((val - 10) / 2)

const resolveVariables = (formula, context) => {
  if (!context || !formula || !formula.includes('@')) return formula

  return formula.replace(/@(\w+)/g, (match, key) => {
    const lowerKey = key.toLowerCase()

    // 1. Check Modifiers (e.g. dexMod)
    if (lowerKey.endsWith('mod')) {
      const stat = lowerKey.replace('mod', '') // 'str'
      if (context.stats) {
        // Try lowercase first
        const val = context.stats[stat]
        if (val !== undefined) {
          return calculateModifier(val)
        }
      }
    }

    // 2. Check Stats directly (e.g. dex)
    if (context.stats) {
      const val = context.stats[lowerKey]
      if (val !== undefined) return val
    }

    // 3. Check Top-level (e.g. hp, ac)
    const topVal = context[lowerKey]
    if (topVal !== undefined) return topVal

    return match
  })
}

const handleNpcAbilityRoll = async (ability) => {
  if (!ability) return
  const context = activeNpcSheet.value

  // 1. Explicit Attack Formula (The "To Hit" Roll)
  if (ability.attack_formula) {
    const resolvedFormula = resolveVariables(ability.attack_formula, context)
    const rollResult = roll(resolvedFormula, ability.name, 'attack')

    // Attach Damage Formula for the UI to use (for the "Roll Damage" button)
    if (ability.damage_formula) {
      // Resolve damage formula NOW so it works even if sheet is closed later
      rollResult.damageFormula = resolveVariables(ability.damage_formula, context)
    }

    if (rollResult) await sendMessage(sessionId, JSON.stringify(rollResult))
    return
  }

  // 2. Explicit Damage Formula Only (e.g. Area of Effect, Magic Missile)
  if (ability.damage_formula) {
    const resolvedFormula = resolveVariables(ability.damage_formula, context)
    const rollResult = roll(resolvedFormula, ability.name, 'damage')
    if (rollResult) await sendMessage(sessionId, JSON.stringify(rollResult))
    return
  }

  // [NEW] Support direct formulas (Stats, Init)
  if (ability.formula) {
    const resolvedFormula = resolveVariables(ability.formula, context)
    const rollResult = roll(resolvedFormula, ability.name, ability.context || 'generic')
    if (rollResult) await sendMessage(sessionId, JSON.stringify(rollResult))
    return
  }

  // Check for formula in effect
  if (ability.effect) {
    let formula = ability.effect

    // Extract 1d20+5 or 2d6 etc if mixed with text
    // Regex: digits 'd' digits (optional + or - digits)
    const diceRegex = /(\d+d\d+(?:\s*[+\-]\s*\d+)?)/i
    const match = formula.match(diceRegex)
    if (match) {
      formula = match[0]
    }

    // Simple context guessing
    let contextType = 'generic'
    const lowerDesc = (ability.description || '').toLowerCase()
    if (lowerDesc.includes('attack') || lowerDesc.includes('hit')) contextType = 'attack'
    else if (lowerDesc.includes('damage')) contextType = 'damage'
    else if (lowerDesc.includes('save') || lowerDesc.includes('saving throw')) contextType = 'save'
    else if (lowerDesc.includes('cure') || lowerDesc.includes('heal')) contextType = 'spell'

    const rollResult = roll(formula, ability.name, contextType)

    if (rollResult) {
      // Send as JSON
      await sendMessage(sessionId, JSON.stringify(rollResult))
    } else {
      // Fallback text if roll fails
      await sendMessage(sessionId, `**${ability.name}**\n${ability.effect}`)
    }
  } else {
    // Just text
    const content = `**${ability.name}**\n${ability.description}`
    await sendMessage(sessionId, content)
  }
}


// --- Lifecycle ---
onMounted(async () => {
  // Check User Auth
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    router.push('/')
    return
  }
  currentUserId.value = user.id // [NEW]

  // Fetch Session
  const { data: session, error } = await supabase
    .from('sessions')
    .select('*')
    .eq('id', sessionId)
    .single()

  if (error || !session) {
    console.error('Session not found:', error)
    router.push('/dashboard')
    return
  }

  sessionName.value = session.name
  sessionCreatedAt.value = session.created_at
  storageConfig.value = session.storage_config || {}
  if (session.system) campaignSystem.value = session.system // Load system

  // Set storage provider
  setConfig(session.storage_provider || 'supabase', session.storage_config || {})

  // Fetch Assets
  await fetchAssets()
  await fetchNotes()
  await fetchMaps()
  await fetchNpcs() // Fetch NPCs

  // Setup Realtime
  setupRealtime()

  // Load actual members for the players list
  // In a real app, you would also listen to presence/online status via Supabase Realtime
  await loadPlayers()
})

const { getMembers } = useCampaignInvites()

const loadPlayers = async () => {
  const result = await getMembers(sessionId)
  if (result.success) {
    // Transform members to player format
    // In future: Merge with realtime presence state
    connectedPlayers.value = result.data.map(member => ({
      id: member.user_id,
      name: member.email || 'Unknown Player', // Use email from our new secure RPC
      role: member.role,
      status: 'offline', // Default to offline until presence is implemented
      avatar: null,
      joined_at: member.joined_at
    }))
  }
}

// --- Note Functions ---
const fetchNotes = async () => {
  const { data: nData } = await supabase.from('campaign_notes').select('*').eq('session_id', sessionId)
  const { data: fData } = await supabase.from('campaign_folders').select('*').eq('session_id', sessionId).eq('type', 'note')

  if (nData) notes.value = nData
  if (fData) noteFolders.value = fData
}

const createNote = async () => {
  const { data, error } = await supabase.from('campaign_notes').insert({
    session_id: sessionId,
    title: 'Untitled',
    content: ''
  }).select().single()

  if (data) {
    notes.value.push(data)
    openNote(data)
  }
}

const createNoteFolder = async () => {
  const name = prompt('Folder Name:')
  if (!name) return

  const { data } = await supabase.from('campaign_folders').insert({
    session_id: sessionId,
    name: name,
    type: 'note'
  }).select().single()

  if (data) noteFolders.value.push(data)
}

const updateNote = async (updatedNote) => {
  // Optimistic update
  const index = notes.value.findIndex(n => n.id === updatedNote.id)
  if (index !== -1) notes.value[index] = updatedNote

  await supabase.from('campaign_notes').update({
    title: updatedNote.title,
    content: updatedNote.content,
    tags: updatedNote.tags,
    updated_at: new Date()
  }).eq('id', updatedNote.id)
}

const deleteNote = async (note) => {
  if (!confirm('Delete note?')) return
  await supabase.from('campaign_notes').delete().eq('id', note.id)

  // Updates Notes List
  notes.value = notes.value.filter(n => n.id !== note.id)
  if (activeNote.value?.id === note.id) activeNote.value = null

  // Update NPCs that linked to this note
  const linkedNpc = npcs.value.find(npc => npc.note_id === note.id)
  if (linkedNpc) {
    linkedNpc.note_id = null
    // We should ideally update DB too, but if FK exists it would handle it.
    // If no FK, we must update manually.
    await supabase.from('campaign_npcs').update({ note_id: null }).eq('id', linkedNpc.id)
  }
}

const deleteNoteFolder = async (folder) => {
  if (!confirm(`Delete folder "${folder.name}"?`)) return
  await supabase.from('campaign_folders').delete().eq('id', folder.id)
  // Cascade deletes notes in DB. UI update:
  noteFolders.value = noteFolders.value.filter(f => f.id !== folder.id)
  notes.value = notes.value.filter(n => n.folder_id !== folder.id)
}

const openNote = (note) => {
  activeNote.value = note
  modals.notes.open = true
}

const moveNoteItem = async (event) => {
  const { type, id, targetFolderId } = event

  if (type === 'note') {
    await supabase.from('campaign_notes').update({ folder_id: targetFolderId }).eq('id', id)
    const note = notes.value.find(n => n.id === id)
    if (note) note.folder_id = targetFolderId
  }
}

// --- Asset Functions (with Folders) ---
const folders = ref([])
const currentFolderId = ref(null) // null = root

const currentFolder = computed(() => {
  return folders.value.find(f => f.id === currentFolderId.value)
})

const fetchAssets = async () => {
  // 1. Fetch Assets
  const { data: assetsData, error: assetsError } = await supabase
    .from('assets')
    .select('*')
    .eq('session_id', sessionId)
    .order('created_at', { ascending: false })

  if (!assetsError) assets.value = assetsData || []

  // 2. Fetch Folders
  const { data: foldersData, error: foldersError } = await supabase
    .from('campaign_folders')
    .select('*')
    .eq('session_id', sessionId)
    .order('name', { ascending: true })

  if (!foldersError) folders.value = foldersData || []
}

const createFolder = async () => {
  const name = prompt('New Folder Name:')
  if (!name) return

  const { error } = await supabase
    .from('campaign_folders')
    .insert({
      session_id: sessionId,
      name: name,
      parent_id: currentFolderId.value
    })

  if (error) {
    alert('Error creating folder')
  } else {
    await fetchAssets()
  }
}

const openFolder = (folderId) => {
  currentFolderId.value = folderId
}

const moveAssetToFolder = async (asset, targetFolderId) => {
  if (asset.folder_id === targetFolderId) return

  await supabase
    .from('assets')
    .update({ folder_id: targetFolderId })
    .eq('id', asset.id)

  await fetchAssets()
}

const getAssetUrl = (asset) => {
  return storage.value.getUrl(asset.file_path)
}

const onFileChange = async (event) => {
  const files = Array.from(event.target.files)
  await uploadFiles(files)
}

const onFileDrop = async (event) => {
  const files = Array.from(event.dataTransfer.files).filter(f => f.type.startsWith('image/'))
  await uploadFiles(files)
}

const uploadFiles = async (files) => {
  if (files.length === 0) return
  isUploading.value = true

  for (const file of files) {
    try {
      const compressed = await imageCompression(file, { maxSizeMB: 1, maxWidthOrHeight: 1920 })
      const timestamp = Date.now()
      const fileName = `${timestamp}_${file.name}`
      const filePath = `${sessionId}/${fileName}`

      const result = await storage.value.upload(compressed, filePath)

      if (result.error) {
        console.error('Upload error:', result.error)
        continue
      }

      await supabase.from('assets').insert({
        session_id: sessionId,
        file_name: fileName,
        file_path: result.path,
        is_revealed: false,
        folder_id: currentFolderId.value // Upload to current folder
      })
    } catch (err) {
      console.error('Upload error:', err)
    }
  }

  isUploading.value = false
  await fetchAssets()
}

const renameAsset = async (asset, newName = null) => {
  const name = newName || prompt('Enter new name:', asset.display_name || asset.file_name)
  if (!name) return

  await supabase
    .from('assets')
    .update({ display_name: name })
    .eq('id', asset.id)

  await fetchAssets()
}

const deleteAsset = async (asset) => {
  if (!confirm('Delete this asset?')) return

  await storage.value.delete(asset.file_path)
  await supabase.from('assets').delete().eq('id', asset.id)
  await fetchAssets()
}

const deleteFolder = async (folder) => {
  if (!confirm(`Delete folder "${folder.name}" and ALL its contents (images and subfolders)? This cannot be undone.`)) return

  // 1. Find all descendant folder IDs (recursive)
  const getAllDescendantIds = (parentId) => {
    const children = folders.value.filter(f => f.parent_id === parentId)
    let ids = children.map(c => c.id)
    children.forEach(c => {
      ids = [...ids, ...getAllDescendantIds(c.id)]
    })
    return ids
  }

  const folderIdsToDelete = [folder.id, ...getAllDescendantIds(folder.id)]

  // 2. Find all assets in these folders
  const assetsToDelete = assets.value.filter(a => folderIdsToDelete.includes(a.folder_id))

  // 3. Delete files from Storage
  for (const asset of assetsToDelete) {
    await storage.value.delete(asset.file_path)
  }

  // 4. Delete assets from DB explicitly (To ensure cleanup)
  if (assetsToDelete.length > 0) {
    await supabase.from('assets').delete().in('id', assetsToDelete.map(a => a.id))
  }

  // 5. Delete the folder (Cascade will handle subfolders in DB)
  await supabase.from('campaign_folders').delete().eq('id', folder.id)

  // 6. Refresh
  await fetchAssets()

  // Reset view if current was deleted
  if (folderIdsToDelete.includes(currentFolderId.value)) {
    currentFolderId.value = null
  }
}

const toggleBlur = () => {
  blurMode.value = !blurMode.value
}

// [NEW] Asset Picker Logic
const handlePickImage = () => {
  isPickingImage.value = true
  modals.assets.open = true // Open asset sidebar to let user choose
}

const openLightbox = (asset) => {
  // If in picker mode, select the image instead of opening lightbox
  if (isPickingImage.value) {
    const url = getAssetUrl(asset)

    // Generic Callback (e.g. Map BG)
    if (pickerCallback.value) {
      pickerCallback.value(url)
      pickerCallback.value = null
    }
    // Fallback: Note Editor (Legacy direct check)
    else if (activeNote.value && noteEditorRef.value) {
      noteEditorRef.value.editor?.chain().focus().setImage({ src: url }).run()
    }

    isPickingImage.value = false
    modals.assets.open = false // Close asset sidebar after pick
    return
  }

  lightboxAsset.value = asset
}

const closeLightbox = () => {
  lightboxAsset.value = null
}

const broadcastImage = async () => {
  if (!lightboxAsset.value) return

  await supabase
    .from('assets')
    .update({ is_revealed: true })
    .eq('id', lightboxAsset.value.id)

  channel.value?.send({
    type: 'broadcast',
    event: 'reveal',
    payload: { assetId: lightboxAsset.value.id }
  })

  await fetchAssets()
  lightboxAsset.value = assets.value.find(a => a.id === lightboxAsset.value.id)
}

const hideImage = async () => {
  if (!lightboxAsset.value) return

  await supabase
    .from('assets')
    .update({ is_revealed: false })
    .eq('id', lightboxAsset.value.id)

  channel.value?.send({
    type: 'broadcast',
    event: 'hide',
    payload: { assetId: lightboxAsset.value.id }
  })

  await fetchAssets()
  lightboxAsset.value = assets.value.find(a => a.id === lightboxAsset.value.id)
}

const hideImageFromStream = () => {
  streamHiddenState.value = true
}

const restoreStream = () => {
  streamHiddenState.value = false
}

const setupRealtime = () => {
  channel.value = supabase.channel(`session:${sessionId}`)
  channel.value
    .on('postgres_changes', { event: '*', schema: 'public', table: 'assets', filter: `session_id=eq.${sessionId}` }, () => {
      fetchAssets()
    })
    .subscribe()
}
</script>
