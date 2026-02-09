<template>
  <div class="h-14 bg-card border-b border-border flex items-center px-4 shadow-lg relative z-20">
    <!-- Left: Zoom Controls -->
    <div class="flex items-center gap-2">
      <Button @click="$emit('zoom-in')" variant="ghost" size="sm" class="h-8 w-8 p-0">
        <ZoomIn class="h-4 w-4" />
      </Button>

      <span class="text-xs font-mono text-muted-foreground min-w-[3rem] text-center">{{ Math.round(zoom * 100)
        }}%</span>

      <Button @click="$emit('zoom-out')" variant="ghost" size="sm" class="h-8 w-8 p-0">
        <ZoomOut class="h-4 w-4" />
      </Button>

      <div class="w-px h-6 bg-border mx-2"></div>

      <!-- Grid Toggle -->
      <Button @click="$emit('toggle-grid')" :variant="showGrid ? 'default' : 'secondary'" size="sm" class="gap-2">
        <Grid3X3 class="h-3.5 w-3.5" />
        Grade
      </Button>

      <!-- Settings -->
      <Button @click="$emit('open-settings')" variant="default" size="sm" class="gap-2">
        <Settings class="h-3.5 w-3.5" />
        Config.
      </Button>

      <!-- Layers Dropdown -->
      <div class="relative">
        <Button @click="layersOpen = !layersOpen" variant="outline" size="sm" class="gap-2">
          <Layers class="h-3.5 w-3.5" />
          {{ currentLayerLabel }}
          <ChevronDown class="h-3 w-3" />
        </Button>

        <div v-if="layersOpen"
          class="absolute top-full left-0 mt-1 bg-card border border-border rounded-lg shadow-xl z-40 min-w-[140px]">
          <button @click="selectLayer('map')"
            class="w-full px-3 py-2 text-left text-sm hover:bg-muted transition-colors"
            :class="currentLayer === 'map' ? 'text-foreground font-bold' : 'text-muted-foreground'">
            Camada Mapa
          </button>
          <button @click="selectLayer('gm')" class="w-full px-3 py-2 text-left text-sm hover:bg-muted transition-colors"
            :class="currentLayer === 'gm' ? 'text-foreground font-bold' : 'text-muted-foreground'">
            Camada GM
          </button>
          <button @click="selectLayer('tokens')"
            class="w-full px-3 py-2 text-left text-sm hover:bg-muted transition-colors"
            :class="currentLayer === 'tokens' ? 'text-foreground font-bold' : 'text-muted-foreground'">
            Camada Tokens
          </button>
        </div>
      </div>
    </div>

    <!-- Right: Tools -->
    <div class="flex items-center gap-2">
      <div class="w-px h-6 bg-border mx-2"></div>

      <div class="flex items-center bg-muted/50 rounded-lg p-1 border border-border">
        <Button @click="$emit('select-tool', 'move')" :variant="currentTool === 'move' ? 'secondary' : 'ghost'"
          size="sm" class="h-7 px-2 gap-2">
          <MousePointer2 class="h-3.5 w-3.5" />
          <span class="sr-only">Mover</span>
        </Button>

        <Button @click="$emit('select-tool', 'draw')" :variant="currentTool === 'draw' ? 'secondary' : 'ghost'"
          size="sm" class="h-7 px-2 gap-2" disabled title="Desenhar (Em Breve)">
          <Pencil class="h-3.5 w-3.5" />
          <span class="sr-only">Desenhar</span>
        </Button>

        <Button @click="$emit('select-tool', 'clear')" variant="ghost" size="sm" class="h-7 px-2 gap-2" disabled
          title="Limpar (Em Breve)">
          <Ban class="h-3.5 w-3.5" />
          <span class="sr-only">Limpar</span>
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Button } from '@/components/ui/button'
import {
  ZoomIn,
  ZoomOut,
  Grid3X3,
  Settings,
  Layers,
  MousePointer2,
  Pencil,
  Ban,
  ChevronDown
} from 'lucide-vue-next'

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
    map: 'Mapa',
    gm: 'GM',
    tokens: 'Tokens'
  }
  return labels[props.currentLayer] || 'Mapa'
})

const selectLayer = (layer) => {
  layersOpen.value = false
  emit('change-layer', layer)
}

</script>
