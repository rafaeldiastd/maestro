<script setup>
import { ref, computed } from 'vue'
import { UploadCloud, Image as ImageIcon, FolderPlus, Search, ChevronRight, ArrowLeft } from 'lucide-vue-next'
import CampaignGrid from '../CampaignGrid.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

const props = defineProps({
  assets: { type: Array, default: () => [] },
  folders: { type: Array, default: () => [] },
  currentFolderId: { type: String, default: null },
  viewMode: { type: String, default: 'grid' },
  blurMode: { type: Boolean, default: false },
  isUploading: { type: Boolean, default: false },
  getAssetUrl: { type: Function, required: true }
})

const emit = defineEmits([
  'file-upload',
  'file-drop',
  'open-lightbox',
  'rename',
  'delete',
  'update:viewMode',
  'toggle-blur',
  'create-folder',
  'open-folder',
  'delete-folder',
  'move-asset'
])

const fileInput = ref(null)
const searchQuery = ref('')

// --- Filtering ---
const filteredFolders = computed(() => {
  let items = props.folders

  // 1. Filter by Parent (Navigation)
  if (!searchQuery.value) {
    items = items.filter(f => f.parent_id === props.currentFolderId)
  }

  // 2. Search
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    items = items.filter(f => f.name.toLowerCase().includes(q))
  }

  return items
})

const filteredAssets = computed(() => {
  let items = props.assets

  // 1. Filter by Folder
  if (!searchQuery.value) {
    items = items.filter(a => a.folder_id === props.currentFolderId)
  }

  // 2. Search
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    items = items.filter(a => {
      const name = a.display_name || a.file_name
      return name.toLowerCase().includes(q)
    })
  }

  return items
})

const currentFolderName = computed(() => {
  if (!props.currentFolderId) return 'Raiz'
  const folder = props.folders.find(f => f.id === props.currentFolderId)
  return folder ? folder.name : 'Desconhecido'
})

// --- Handlers ---
const handleFileSelect = (event) => {
  emit('file-upload', event)
}

const handleDrop = (event) => {
  emit('file-drop', event)
}

const triggerUpload = () => {
  fileInput.value?.click()
}
</script>

<template>
  <div class="flex flex-col h-full">

    <!-- Actions Bar: Search & Breadcrumbs -->
    <div class="p-4 border-b border-lumina-border shrink-0 space-y-3">

      <!-- Search -->
      <div class="relative">
        <Search class="absolute left-2 top-2 h-4 w-4 text-lumina-text-muted" />
        <Input v-model="searchQuery" placeholder="Buscar arquivos..."
          class="pl-8 h-8 text-xs bg-lumina-bg border-lumina-border text-lumina-text" />
      </div>

      <!-- Navigation & Tools -->
      <div class="flex items-center justify-between">
        <!-- Breadcrumbs -->
        <div class="flex items-center gap-1 text-xs font-medium text-lumina-text-muted overflow-hidden">
          <button @click="$emit('open-folder', null)"
            class="hover:text-lumina-text transition-colors flex items-center gap-1"
            :class="{ 'text-lumina-text': !currentFolderId }">
            <ImageIcon class="h-3 w-3" /> Raiz
          </button>

          <template v-if="currentFolderId">
            <ChevronRight class="h-3 w-3" />
            <span class="text-lumina-text truncate max-w-[100px]">{{ currentFolderName }}</span>
          </template>
        </div>

        <!-- Actions -->
        <div class="flex items-center gap-1">
          <Button variant="ghost" size="icon" class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text"
            title="Nova Pasta" @click="$emit('create-folder')">
            <FolderPlus class="h-3 w-3" />
          </Button>
        </div>
      </div>
    </div>

    <!-- Upload Zone (Compact if not root?) -> Keep always visible for easy drop -->
    <div class="px-4 py-2 border-b border-lumina-border shrink-0 bg-lumina-bg/20">
      <div
        class="group relative flex h-16 w-full cursor-pointer flex-col items-center justify-center rounded-lg border border-dashed border-lumina-border bg-lumina-bg/30 transition-all hover:border-lumina-detail hover:bg-lumina-bg/50"
        :class="isUploading ? 'pointer-events-none opacity-50' : ''" @click="triggerUpload" @dragover.prevent
        @drop.prevent="handleDrop">

        <input ref="fileInput" type="file" class="hidden" multiple accept="image/*" @change="handleFileSelect" />

        <div class="flex items-center gap-2 text-lumina-text-muted">
          <UploadCloud class="h-4 w-4 group-hover:text-lumina-text" />
          <span class="text-xs font-medium group-hover:text-lumina-accent">
            {{ isUploading ? 'Enviando...' : 'Enviar Imagem' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Grid -->
    <div class="flex-1 overflow-hidden">
      <CampaignGrid :assets="filteredAssets" :folders="filteredFolders" :view-mode="viewMode" :blur-mode="blurMode"
        :get-asset-url="getAssetUrl" @file-drop="handleDrop" @open-folder="$emit('open-folder', $event)"
        @delete-folder="$emit('delete-folder', $event)"
        @move-asset="$emit('move-asset', $event.asset, $event.targetFolderId)"
        @open-lightbox="$emit('open-lightbox', $event)" @rename="$emit('rename', $event)"
        @delete="$emit('delete', $event)" />
    </div>
  </div>
</template>
