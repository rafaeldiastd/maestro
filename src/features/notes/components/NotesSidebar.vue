<script setup>
import { ref, computed } from 'vue'
import { Folder, FileText, Plus, FolderPlus, ChevronRight, ChevronDown, Trash2, Search, X } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

const props = defineProps({
  folders: { type: Array, default: () => [] }, // Only type='note'
  notes: { type: Array, default: () => [] },
  isOpen: Boolean
})

const emit = defineEmits([
  'close',
  'create-note',
  'create-folder',
  'delete-note',
  'delete-folder',
  'open-note',
  'move-item' // item, targetFolderId
])

const searchQuery = ref('')
const expandedFolders = ref(new Set())

const toggleFolder = (folderId) => {
  if (expandedFolders.value.has(folderId)) {
    expandedFolders.value.delete(folderId)
  } else {
    expandedFolders.value.add(folderId)
  }
}

// Interactive Tree Building
const tree = computed(() => {
  const rootNotes = props.notes.filter(n => !n.folder_id)
  const rootFolders = props.folders.filter(f => !f.parent_id)

  const buildNode = (folder) => {
    const childrenFolders = props.folders.filter(f => f.parent_id === folder.id)
    const childrenNotes = props.notes.filter(n => n.folder_id === folder.id)

    return {
      ...folder,
      type: 'folder',
      children: [
        ...childrenFolders.map(buildNode),
        ...childrenNotes.map(n => ({ ...n, type: 'note' }))
      ]
    }
  }

  // Filter if search is active (flattened or keep tree? Flattened is easier for search)
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    return [
      ...props.folders.filter(f => f.name.toLowerCase().includes(q)).map(f => ({ ...f, type: 'folder', children: [] })),
      ...props.notes.filter(n => n.title.toLowerCase().includes(q)).map(n => ({ ...n, type: 'note' }))
    ]
  }

  return [
    ...rootFolders.map(buildNode),
    ...rootNotes.map(n => ({ ...n, type: 'note' }))
  ]
})

// DnD
const handleDragStart = (event, item, type) => {
  event.dataTransfer.effectAllowed = 'move'
  event.dataTransfer.setData('application/json', JSON.stringify({ type, id: item.id }))
}

const handleDrop = (event, targetFolder) => {
  const data = event.dataTransfer.getData('application/json')
  if (!data) return

  try {
    const payload = JSON.parse(data)
    if (payload.id === targetFolder.id) return // Can't drop on self

    // Emit move event
    emit('move-item', {
      type: payload.type,
      id: payload.id,
      targetFolderId: targetFolder.id
    })
  } catch (e) {
    console.error('DnD Error', e)
  }
}

// Recursive Tree Component (Local Component for simplicity)
</script>

<template>
  <div class="h-full w-full flex flex-col bg-card">
    <!-- Header -->
    <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-card">
      <div class="flex items-center gap-2">
        <FileText class="h-4 w-4 text-lumina-detail" />
        <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Notas</span>
      </div>
      <Button variant="ghost" size="icon"
        class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg" @click="$emit('close')">
        <X class="h-4 w-4" />
      </Button>
    </div>

    <!-- Actions -->
    <div class="p-3 border-b border-lumina-border flex gap-2">
      <div class="relative flex-1">
        <Search class="absolute left-2 top-2 h-3.5 w-3.5 text-lumina-text-muted" />
        <Input v-model="searchQuery" placeholder="Buscar..."
          class="h-8 text-xs pl-8 bg-lumina-bg border-lumina-border" />
      </div>
      <Button @click="$emit('create-folder')" size="icon" variant="ghost"
        class="h-8 w-8 text-lumina-text-muted hover:text-green-400" title="Nova Pasta">
        <FolderPlus class="h-4 w-4" />
      </Button>
      <Button @click="$emit('create-note')" size="icon" variant="ghost"
        class="h-8 w-8 text-lumina-text-muted hover:text-lumina-detail" title="Nova Nota">
        <Plus class="h-4 w-4" />
      </Button>
    </div>

    <!-- Tree -->
    <div class="flex-1 overflow-y-auto p-2 scrollbar-thin">
      <template v-for="item in tree" :key="item.id">
        <!-- Folder Node -->
        <div v-if="item.type === 'folder'" class="mb-1">
          <div
            class="group flex items-center gap-1 p-1.5 rounded cursor-pointer hover:bg-lumina-bg/50 text-lumina-text transition-colors"
            @click="toggleFolder(item.id)" @dragover.prevent @drop.stop="handleDrop($event, item)">
            <ChevronDown v-if="expandedFolders.has(item.id) || searchQuery" class="h-3 w-3 text-lumina-text-muted" />
            <ChevronRight v-else class="h-3 w-3 text-lumina-text-muted" />

            <Folder class="h-3.5 w-3.5 text-lumina-detail/70" />
            <span class="text-sm truncate flex-1 select-none">{{ item.name }}</span>

            <button @click.stop="$emit('delete-folder', item)"
              class="opacity-0 group-hover:opacity-100 p-1 hover:text-red-400 transition-opacity">
              <Trash2 class="h-3 w-3" />
            </button>
          </div>

          <!-- Children (Recursive-ish manual loop for 1 level deep? No, use CSS indent for simple depth or recursion) -->
          <!-- For robust unlimited nesting, a recursive component is best. But here we can just iterate children if expanded -->
          <div v-if="(expandedFolders.has(item.id) || searchQuery) && item.children"
            class="pl-4 border-l border-lumina-border/20 ml-2">
            <div v-for="child in item.children" :key="child.id">
              <!-- Sub-Folder (Simplified: just identifying type. Real recursion would need a separate component file to be clean) -->
              <!-- Let's handle 1 level of nesting visually or assume flattened for MVP? User asked for folders. -->
              <!-- Implementing a simple recursion via v-for if I extracted TreeItem. But to keep it single-file: -->

              <div v-if="child.type === 'note'"
                class="group flex items-center gap-2 p-1.5 rounded cursor-pointer hover:bg-lumina-bg text-lumina-text-muted hover:text-lumina-text border border-transparent hover:border-lumina-border/50 ml-1"
                draggable="true" @dragstart="handleDragStart($event, child, 'note')" @click="$emit('open-note', child)">
                <FileText class="h-3.5 w-3.5" />
                <span class="text-sm truncate flex-1">{{ child.title }}</span>
                <button @click.stop="$emit('delete-note', child)"
                  class="opacity-0 group-hover:opacity-100 p-1 hover:text-red-400 transition-opacity">
                  <Trash2 class="h-3 w-3" />
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Root Note -->
        <div v-else
          class="group flex items-center gap-2 p-1.5 rounded cursor-pointer hover:bg-lumina-bg text-lumina-text-muted hover:text-lumina-text border border-transparent hover:border-lumina-border/50"
          draggable="true" @dragstart="handleDragStart($event, item, 'note')" @click="$emit('open-note', item)">
          <FileText class="h-3.5 w-3.5" />
          <span class="text-sm truncate flex-1">{{ item.title }}</span>
          <button @click.stop="$emit('delete-note', item)"
            class="opacity-0 group-hover:opacity-100 p-1 hover:text-red-400 transition-opacity">
            <Trash2 class="h-3 w-3" />
          </button>
        </div>
      </template>

      <div v-if="tree.length === 0" class="text-center py-10 text-lumina-text-muted text-xs">
        <p>Sem notas</p>
        <p>Crie uma para começar a escrever</p>
      </div>
    </div>
  </div>
</template>
