<script setup>
import { computed } from 'vue'
import { Eye, Pencil, Trash2, Folder, Image as ImageIcon } from 'lucide-vue-next'

const props = defineProps({
   assets: Array,
   folders: { type: Array, default: () => [] },
   viewMode: String,
   blurMode: Boolean,
   getAssetUrl: Function // Function prop to resolve URL
})

const emit = defineEmits([
  'file-drop', 
  'open-lightbox', 
  'rename', 
  'delete',
  'open-folder',
  'delete-folder',
  'move-asset'
])

const gridClasses = computed(() => {
  if (props.viewMode === 'small') return 'grid-cols-4'
  return 'grid-cols-3'
})

const getCardClasses = (asset) => {
  if (asset.is_revealed) return 'border-green-500/50 bg-green-500/5'
  return ''
}

const getDisplayName = (fullName) => {
  const parts = fullName.split('_')
  if (parts.length > 1 && !isNaN(parts[0])) {
    return parts.slice(1).join('_')
  }
  return fullName
}

// --- DnD ---
const handleDragStart = (event, asset) => {
  event.dataTransfer.effectAllowed = 'move'
  event.dataTransfer.setData('application/json', JSON.stringify({ type: 'asset', id: asset.id }))
  // Store full asset in store or assume parent knows it by ID. 
  // For simplicity, passing ID and emitting generic event.
}

const handleFolderDrop = (event, folder) => {
  const data = event.dataTransfer.getData('application/json')
  if (!data) return

  try {
     const payload = JSON.parse(data)
     if (payload.type === 'asset') {
        // Emit move event: Asset ID -> Target Folder ID
        // We need to pass the asset object, but we only have ID here if we don't look it up.
        // Let's modify the emit to pass just ID or look it up in parent. 
        // Better: Find it in props.assets (if it's currently visible) OR rely on ID.
        // The parent 'move-asset' handler in MasterCampaignView.vue expects (asset, folderId).
        // Let's find the asset from props.
        const asset = props.assets.find(a => a.id === payload.id)
        if (asset) {
            emit('move-asset', { asset, targetFolderId: folder.id })
        }
     }
  } catch (e) {
     console.error('Invalid drop data', e)
  }
}
</script>

<template>
  <div 
      class="flex-1 overflow-y-auto p-4 scrollbar-thin scrollbar-track-lumina-bg scrollbar-thumb-lumina-border relative"
      @dragover.prevent
      @drop.prevent="$emit('file-drop', $event)">
      
      <!-- Empty State -->
      <div v-if="assets.length === 0 && folders.length === 0" class="flex h-full flex-col items-center justify-center text-lumina-text-muted pointer-events-none">
         <div class="p-4 rounded-full bg-lumina-card mb-4 border border-lumina-border">
            <image-icon class="h-8 w-8 opacity-50" />
         </div>
         <p class="text-sm font-medium">No assets</p>
         <p class="text-xs text-lumina-text-muted mt-1">Drop files here</p>
      </div>

      <!-- Grid -->
      <div v-else :class="gridClasses" class="grid gap-3 pb-20">
         
         <!-- Folders -->
         <div 
            v-for="folder in folders" 
            :key="folder.id"
            class="group relative aspect-square overflow-hidden rounded-md border border-lumina-border bg-lumina-card/50 transition-all cursor-pointer hover:border-lumina-text hover:bg-lumina-card flex flex-col items-center justify-center gap-2"
            @click="$emit('open-folder', folder.id)"
            @dragover.prevent
            @drop.stop="handleFolderDrop($event, folder)"
         >
            <Folder class="h-10 w-10 text-lumina-detail fill-lumina-detail/10" />
            <span class="text-xs font-medium text-lumina-text truncate w-[80%] text-center px-1">{{ folder.name }}</span>
            
            <!-- Folder Actions -->
            <button 
               @click.stop="$emit('delete-folder', folder)"
               class="absolute top-2 right-2 p-1 rounded hover:bg-red-500/20 text-lumina-text-muted hover:text-red-400 opacity-0 group-hover:opacity-100 transition-opacity"
               title="Delete Folder"
            >
               <Trash2 class="h-3 w-3" />
            </button>
         </div>

         <!-- Assets -->
         <div 
            v-for="asset in assets" 
            :key="asset.id"
            class="group relative overflow-hidden rounded-md border border-lumina-border bg-lumina-card transition-all cursor-pointer hover:border-lumina-text-muted"
            :class="getCardClasses(asset)"
            draggable="true"
            @dragstart="handleDragStart($event, asset)"
            @click="$emit('open-lightbox', asset)">

            <!-- Status Indicators -->
            <div class="absolute top-2 right-2 z-10 flex gap-1 pointer-events-none">
               <span v-if="asset.is_revealed" 
                  class="flex items-center justify-center h-5 w-5 rounded-full bg-green-500/90 text-white shadow-sm ring-1 ring-black/20">
                  <Eye class="h-3 w-3" />
               </span>
            </div>

            <!-- Image -->
            <div class="aspect-square w-full overflow-hidden bg-lumina-bg relative">
               <img 
                  :src="getAssetUrl(asset)" 
                  loading="lazy" 
                  class="h-full w-full object-cover transition-all duration-500 group-hover:scale-105"
                  :class="{ 
                     'blur-md': blurMode, 
                     'opacity-50 grayscale': !asset.is_revealed 
                  }"
               >
               <div class="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors"></div>
            </div>

            <!-- Footer / Actions -->
            <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/90 via-black/50 to-transparent p-3 opacity-0 transition-opacity group-hover:opacity-100 flex items-end justify-between pt-8">
               
               <p class="truncate text-[10px] font-medium text-white max-w-[70%] drop-shadow-sm font-mono">
                  {{ asset.display_name || getDisplayName(asset.file_name) }}
               </p>

               <div class="flex items-center gap-1">
                  <button 
                     @click.stop="$emit('rename', asset)" 
                     title="Rename" 
                     class="p-1 rounded hover:bg-white/20 text-lumina-text-muted hover:text-white transition-colors">
                     <Pencil class="h-3 w-3" />
                  </button>
               </div>
            </div>

            <!-- Delete Action (Hover Top Left) -->
            <button 
               @click.stop="$emit('delete', asset)"
               class="absolute top-2 left-2 p-1 rounded bg-black/50 text-white opacity-0 group-hover:opacity-100 hover:bg-red-500/90 transition-all backdrop-blur-sm z-20">
               <Trash2 class="h-3 w-3" />
            </button>

         </div>
      </div>
  </div>
</template>
