<template>
  <div class="fixed left-16 top-0 bottom-0 z-40 w-96 bg-card border-r border-border shadow-2xl">
    <div class="h-full flex flex-col">
      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-border flex items-center justify-between px-4 bg-card">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" class="text-lumina-detail">
            <circle cx="12" cy="12" r="3" />
            <path
              d="M12 1v6m0 6v6M5.64 5.64l4.24 4.24m4.24 4.24l4.24 4.24M1 12h6m6 0h6M5.64 18.36l4.24-4.24m4.24-4.24l4.24-4.24" />
          </svg>
          <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Configurações da Grade</span>
        </div>
        <Button variant="ghost" size="icon"
          class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg" @click="$emit('close')">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </Button>
      </div>

      <!-- Form -->
      <div class="flex-1 overflow-y-auto p-4 space-y-6">
        <!-- Grid Dimensions -->
        <div class="space-y-3">
          <h4 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Dimensões da Grade</h4>

          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Colunas</label>
              <input v-model.number="localSettings.grid_cols" type="number" min="1"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Linhas</label>
              <input v-model.number="localSettings.grid_rows" type="number" min="1"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Cell Size -->
        <div class="space-y-3">
          <h4 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Tamanho da Célula</h4>

          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Largura (px)</label>
              <input v-model.number="localSettings.grid_cell_width" type="number" min="10"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Altura (px)</label>
              <input v-model.number="localSettings.grid_cell_height" type="number" min="10"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Offsets -->
        <div class="space-y-3">
          <h4 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Deslocamento (Gap)</h4>

          <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Esquerda (px)</label>
              <input v-model.number="localSettings.grid_offset_left" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Direita (px)</label>
              <input v-model.number="localSettings.grid_offset_right" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Topo (px)</label>
              <input v-model.number="localSettings.grid_offset_top" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Base (px)</label>
              <input v-model.number="localSettings.grid_offset_bottom" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Line Settings -->
        <div class="space-y-3">
          <h4 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Configurações de Linha</h4>

          <div class="space-y-3">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Cor</label>
              <div class="flex gap-2">
                <input v-model="localSettings.grid_color" type="color"
                  class="h-9 w-16 rounded border border-lumina-border cursor-pointer" />
                <input v-model="localSettings.grid_color" type="text"
                  class="flex-1 bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none font-mono" />
              </div>
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Largura (px)</label>
              <input v-model.number="localSettings.grid_line_width" type="number" min="1" max="10" step="0.5"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-2 py-1.5 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Opacidade</label>
              <div class="flex items-center gap-3">
                <input v-model.number="localSettings.grid_opacity" type="range" min="0" max="1" step="0.05"
                  class="flex-1" />
                <span class="text-xs font-mono w-12 text-lumina-text">{{ Math.round(localSettings.grid_opacity * 100)
                }}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="h-16 shrink-0 border-t border-lumina-border flex items-center justify-end gap-3 px-4">
        <Button @click="$emit('cancel')" variant="outline" size="sm">
          Cancelar
        </Button>
        <Button @click="handleSave" size="sm">
          Salvar Alterações
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { Button } from '@/components/ui/button'

const props = defineProps({
  map: { type: Object, required: true }
})

const emit = defineEmits(['close', 'save', 'preview', 'cancel'])

const localSettings = ref({
  grid_cols: 20,
  grid_rows: 15,
  grid_cell_width: 50,
  grid_cell_height: 50,
  grid_offset_left: 0,
  grid_offset_right: 0,
  grid_offset_top: 0,
  grid_offset_bottom: 0,
  grid_color: '#ffffff',
  grid_opacity: 0.3,
  grid_line_width: 1
})

const initSettings = () => {
  localSettings.value = {
    grid_cols: props.map.grid_cols || 20,
    grid_rows: props.map.grid_rows || 15,
    grid_cell_width: props.map.grid_cell_width || 50,
    grid_cell_height: props.map.grid_cell_height || 50,
    grid_offset_left: props.map.grid_offset_left || 0,
    grid_offset_right: props.map.grid_offset_right || 0,
    grid_offset_top: props.map.grid_offset_top || 0,
    grid_offset_bottom: props.map.grid_offset_bottom || 0,
    grid_color: props.map.grid_color || '#ffffff',
    grid_opacity: props.map.grid_opacity !== undefined ? props.map.grid_opacity : 0.3,
    grid_line_width: props.map.grid_line_width || 1
  }
}

// Initialize on mount or when map ID changes
onMounted(initSettings)
watch(() => props.map.id, initSettings)

// Emit preview on any change
watch(localSettings, (newSettings) => {
  emit('preview', { ...newSettings })
}, { deep: true })

const handleSave = () => {
  emit('save', { ...localSettings.value })
}
</script>
