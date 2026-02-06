<script setup>
import { ref, computed } from 'vue'
import { Plus, Trash2, Map, Check, Image as ImageIcon, X } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

const props = defineProps({
   isOpen: Boolean,
   maps: { type: Array, default: () => [] },
   activeMapId: String
})

const emit = defineEmits(['close', 'create-map', 'delete-map', 'update-map', 'select-map', 'pick-image'])

// Local editing state
const editingMap = computed(() => {
   return props.maps.find(m => m.id === props.activeMapId) || null
})

// Update helper
const updateMap = (key, value) => {
   if (!editingMap.value) return
   emit('update-map', { ...editingMap.value, [key]: value })
}

const handleCreate = () => emit('create-map')
const handleDelete = (map) => emit('delete-map', map)
const handleSelect = (map) => emit('select-map', map)

</script>

<template>
   <div
      class="fixed left-16 top-0 bottom-0 z-30 w-80 bg-card border-r border-border shadow-2xl transition-transform duration-300 flex flex-col"
      :class="isOpen ? 'translate-x-0' : '-translate-x-full'">
      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-border flex items-center justify-between px-4 bg-card">
         <div class="flex items-center gap-2">
            <Map class="h-4 w-4 text-primary" />
            <span class="text-sm font-bold text-foreground font-serif tracking-wide">Map Editor</span>
         </div>
         <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground hover:bg-muted"
            @click="$emit('close')">
            <X class="h-4 w-4" />
         </Button>
      </div>

      <div class="flex-1 overflow-hidden flex flex-col">

         <!-- Map List -->
         <div class="p-4 border-b border-lumina-border max-h-[200px] overflow-y-auto scrollbar-thin shrink-0">
            <div class="flex items-center justify-between mb-2">
               <h3 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Scenarios</h3>
               <Button size="icon-sm" variant="ghost" class="h-6 w-6" @click="handleCreate">
                  <Plus class="h-4 w-4" />
               </Button>
            </div>

            <div class="space-y-1">
               <div v-for="map in maps" :key="map.id"
                  class="flex items-center justify-between p-2 rounded-md cursor-pointer transition-colors group"
                  :class="map.id === activeMapId ? 'bg-lumina-detail/10 text-lumina-detail' : 'hover:bg-lumina-bg/50 text-lumina-text'"
                  @click="handleSelect(map)">
                  <div class="flex items-center gap-2 truncate">
                     <div class="w-2 h-2 rounded-full"
                        :class="map.is_active ? 'bg-green-500' : 'bg-transparent border border-lumina-text-muted'">
                     </div>
                     <span class="text-sm font-medium truncate">{{ map.name }}</span>
                  </div>
                  <Button variant="ghost" size="icon-sm"
                     class="h-6 w-6 opacity-0 group-hover:opacity-100 text-red-400 hover:text-red-500 hover:bg-red-500/10"
                     @click.stop="handleDelete(map)">
                     <Trash2 class="h-3 w-3" />
                  </Button>
               </div>
            </div>
         </div>

         <!-- Editor Form -->
         <div v-if="editingMap" class="flex-1 overflow-y-auto p-4 space-y-6 scrollbar-thin">

            <!-- Name -->
            <div class="space-y-1">
               <label class="text-xs text-lumina-text-muted">Map Name</label>
               <input :value="editingMap.name" @input="updateMap('name', $event.target.value)"
                  class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>



            <!-- Background Settings -->
            <div class="space-y-3 pt-4 border-t border-lumina-border">
               <h4 class="text-xs font-bold text-lumina-text font-serif">Dimensions & Background</h4>

               <div class="space-y-2">
                  <label class="text-xs text-lumina-text-muted">Background Image</label>
                  <div class="flex gap-2">
                     <input :value="editingMap.background_url" @input="updateMap('background_url', $event.target.value)"
                        class="flex-1 bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none truncate"
                        placeholder="Select image..." readonly />
                     <Button variant="outline" size="icon" class="shrink-0" @click="$emit('pick-image')">
                        <ImageIcon class="h-4 w-4" />
                     </Button>
                  </div>
                  <p class="text-[10px] text-lumina-text-muted">
                     Pick an image to auto-set dimensions.
                  </p>
               </div>

               <!-- Image Dimensions (Read Only) -->
               <div class="grid grid-cols-2 gap-4">
                  <div class="space-y-1">
                     <label class="text-xs text-lumina-text-muted">Total Width (px)</label>
                     <input type="number" :value="editingMap.width" readonly
                        class="w-full bg-lumina-bg/50 border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text-muted cursor-not-allowed focus:outline-none" />
                  </div>
                  <div class="space-y-1">
                     <label class="text-xs text-lumina-text-muted">Total Height (px)</label>
                     <input type="number" :value="editingMap.height" readonly
                        class="w-full bg-lumina-bg/50 border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text-muted cursor-not-allowed focus:outline-none" />
                  </div>
               </div>
            </div>

            <!-- Grid Settings -->
            <div class="space-y-3 pt-4 border-t border-lumina-border">
               <h4 class="text-xs font-bold text-lumina-text font-serif">Grid Configuration</h4>

               <div class="flex items-center gap-2">
                  <div class="space-y-1 flex-1">
                     <label class="text-xs text-lumina-text-muted">Cell Width</label>
                     <input type="number" :value="editingMap.grid_cell_width"
                        @input="updateMap('grid_cell_width', Number($event.target.value))"
                        class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                  </div>
                  <div class="space-y-1 flex-1">
                     <label class="text-xs text-lumina-text-muted">Cell Height</label>
                     <input type="number" :value="editingMap.grid_cell_height"
                        @input="updateMap('grid_cell_height', Number($event.target.value))"
                        class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                  </div>
                  <div class="space-y-1 w-20">
                     <label class="text-xs text-lumina-text-muted">Line Width</label>
                     <input type="number" min="1" :value="editingMap.grid_line_width"
                        @input="updateMap('grid_line_width', Number($event.target.value))"
                        class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                  </div>
                  <div class="space-y-1 w-1/4">
                     <label class="text-xs text-lumina-text-muted">Color</label>
                     <div class="flex gap-2">
                        <input type="color" :value="editingMap.grid_color"
                           @input="updateMap('grid_color', $event.target.value)"
                           class="h-8 w-full bg-transparent cursor-pointer" />
                     </div>
                  </div>
               </div>

               <!-- Grid Dimensions -->
               <div class="space-y-2">
                  <label class="text-xs text-lumina-text-muted">Grid Dimensions (Cells)</label>
                  <div class="grid grid-cols-2 gap-4">
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Columns</label>
                        <input type="number" :value="editingMap.grid_cols"
                           @input="updateMap('grid_cols', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Rows</label>
                        <input type="number" :value="editingMap.grid_rows"
                           @input="updateMap('grid_rows', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                  </div>
               </div>

               <!-- Grid Padding (Offsets) -->
               <div class="space-y-2">
                  <label class="text-xs text-lumina-text-muted">Grid Padding (Offsets)</label>
                  <div class="grid grid-cols-2 gap-2">
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Top</label>
                        <input type="number" :value="editingMap.grid_offset_top"
                           @input="updateMap('grid_offset_top', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Bottom</label>
                        <input type="number" :value="editingMap.grid_offset_bottom"
                           @input="updateMap('grid_offset_bottom', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Left</label>
                        <input type="number" :value="editingMap.grid_offset_left"
                           @input="updateMap('grid_offset_left', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                     <div class="space-y-1">
                        <label class="text-[10px] text-lumina-text-muted">Right</label>
                        <input type="number" :value="editingMap.grid_offset_right"
                           @input="updateMap('grid_offset_right', Number($event.target.value))"
                           class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
                     </div>
                  </div>
               </div>

               <p class="text-[10px] text-lumina-text-muted mt-2">
                  Adjust Offsets to align the grid with your map image.
               </p>

            </div>

            <!-- Actions (Bottom) -->
            <div class="pt-4 mt-4 border-t border-lumina-border">
               <Button size="default" :variant="editingMap.is_active ? 'default' : 'outline'"
                  class="w-full justify-center font-bold"
                  :class="editingMap.is_active ? 'bg-green-600 hover:bg-green-700 text-white' : ''"
                  @click="updateMap('is_active', !editingMap.is_active)">
                  <Check v-if="editingMap.is_active" class="mr-2 h-4 w-4" />
                  {{ editingMap.is_active ? 'Map is Active (Live)' : 'Activate Map for Players' }}
               </Button>
            </div>

         </div>
         <div v-else class="flex-1 flex items-center justify-center text-lumina-text-muted text-sm p-4 text-center">
            Select or create a scenario to start editing.
         </div>
      </div>
   </div>
</template>
