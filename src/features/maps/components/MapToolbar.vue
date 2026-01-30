<template>
  <div class="h-14 bg-lumina-card/95 backdrop-blur-xl border-b border-lumina-border flex items-center px-4 shadow-lg relative z-20">
    <!-- Left: Zoom Controls -->
    <div class="flex items-center gap-2">
      <Button @click="$emit('zoom-in')" variant="ghost" size="sm" class="h-8 w-8 p-0">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8" />
          <path d="M21 21l-4.35-4.35M8 11h6" />
        </svg>
      </Button>
      
      <span class="text-xs font-mono text-lumina-text-muted min-w-[3rem] text-center">{{ Math.round(zoom * 100) }}%</span>
      
      <Button @click="$emit('zoom-out')" variant="ghost" size="sm" class="h-8 w-8 p-0">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8" />
          <path d="M21 21l-4.35-4.35M11 8v6M8 11h6" />
        </svg>
      </Button>
      
      <div class="w-px h-6 bg-lumina-border mx-2"></div>
      
      <!-- Grid Toggle -->
      <Button 
        @click="$emit('toggle-grid')" 
        :variant="showGrid ? 'default' : 'secondary'" 
        size="sm"
        class="gap-2"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
        </svg>
        Grid
      </Button>
      
      <!-- Settings -->
      <Button @click="$emit('open-settings')" variant="default" size="sm" class="gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="12" r="3" />
          <path d="M12 1v6m0 6v6M5.64 5.64l4.24 4.24m4.24 4.24l4.24 4.24M1 12h6m6 0h6M5.64 18.36l4.24-4.24m4.24-4.24l4.24-4.24" />
        </svg>
        Settings
      </Button>
      
      <!-- Layers Dropdown -->
      <div class="relative">
        <Button 
          @click="layersOpen = !layersOpen" 
          variant="glass" 
          size="sm"
          class="gap-2"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M12 2L2 7l10 5 10-5-10-5z" />
            <path d="M2 17l10 5 10-5M2 12l10 5 10-5" />
          </svg>
          {{ currentLayerLabel }}
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="m6 9 6 6 6-6" />
          </svg>
        </Button>
        
        <div 
          v-if="layersOpen"
          class="absolute top-full left-0 mt-1 bg-lumina-card border border-lumina-border rounded-lg shadow-xl z-40 min-w-[140px]"
        >
          <button
            @click="selectLayer('map')"
            class="w-full px-3 py-2 text-left text-sm hover:bg-white/10 transition-colors"
            :class="currentLayer === 'map' ? 'text-lumina-text font-bold' : 'text-lumina-text-muted'"
          >
            Map Layer
          </button>
          <button
            @click="selectLayer('gm')"
            class="w-full px-3 py-2 text-left text-sm hover:bg-white/10 transition-colors"
            :class="currentLayer === 'gm' ? 'text-lumina-text font-bold' : 'text-lumina-text-muted'"
          >
            GM Layer
          </button>
          <button
            @click="selectLayer('tokens')"
            class="w-full px-3 py-2 text-left text-sm hover:bg-white/10 transition-colors"
            :class="currentLayer === 'tokens' ? 'text-lumina-text font-bold' : 'text-lumina-text-muted'"
          >
            Tokens Layer
          </button>
        </div>
      </div>
    </div>
    
    <!-- Right: Tools -->
    <div class="flex items-center gap-2">
      <div class="w-px h-6 bg-lumina-border mx-2"></div>
      
      <div class="flex items-center bg-lumina-bg/50 rounded-lg p-1 border border-lumina-border">
        <Button 
          @click="$emit('select-tool', 'move')" 
          :variant="currentTool === 'move' ? 'secondary' : 'ghost'" 
          size="sm"
          class="h-7 px-2 gap-2"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M5 9l-3 3 3 3M9 5l3-3 3 3M15 19l-3 3-3-3M19 9l3 3-3 3M2 12h20M12 2v20" />
          </svg>
          <span class="sr-only">Move</span>
        </Button>
        
        <Button 
          @click="$emit('select-tool', 'draw')" 
          :variant="currentTool === 'draw' ? 'secondary' : 'ghost'" 
          size="sm"
          class="h-7 px-2 gap-2"
          disabled
          title="Draw (Coming Soon)"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M12 19l7-7 3 3-7 7-3-3z" />
            <path d="M18 13l-1.5-7.5L2 2l3.5 14.5L13 18l5-5z" />
            <path d="M2 2l7.586 7.586" />
          </svg>
          <span class="sr-only">Draw</span>
        </Button>
        
        <Button 
          @click="$emit('select-tool', 'clear')" 
          variant="ghost" 
          size="sm"
          class="h-7 px-2 gap-2"
          disabled
          title="Clear (Coming Soon)"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M3 6h18M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
          </svg>
          <span class="sr-only">Clear</span>
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'

const props = defineProps({
  showGrid: { type: Boolean, default: true },
  currentLayer: { type: String, default: 'map' },
  currentTool: { type: String, default: 'move' },
  zoom: { type: Number, default: 1 }
})

const emit = defineEmits(['zoom-in', 'zoom-out', 'toggle-grid', 'open-settings', 'change-layer', 'select-tool'])

const layersOpen = ref(false)

const currentLayerLabel = computed(() => {
  const labels = {
    map: 'Map',
    gm: 'GM',
    tokens: 'Tokens'
  }
  return labels[props.currentLayer] || 'Map'
})

const selectLayer = (layer) => {
  layersOpen.value = false
  emit('change-layer', layer)
}

</script>
