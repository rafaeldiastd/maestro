<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
    @click.self="$emit('close')">
    <div
      class="w-full max-w-2xl bg-lumina-card border border-lumina-border rounded-xl shadow-2xl max-h-[90vh] flex flex-col">
      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-6">
        <h2 class="font-bold text-lg font-inknut text-lumina-text">Configurações da Grade</h2>
        <Button @click="$emit('close')" variant="ghost" size="sm" class="h-8 w-8 p-0">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </Button>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 space-y-6">
        <!-- Grid Dimensions -->
        <div class="space-y-3">
          <h3 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Dimensões da Grade</h3>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Colunas</label>
              <input v-model.number="localMap.grid_cols" type="number" min="1"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Linhas</label>
              <input v-model.number="localMap.grid_rows" type="number" min="1"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Cell Size -->
        <div class="space-y-3">
          <h3 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Tamanho da Célula</h3>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Largura (px)</label>
              <input v-model.number="localMap.grid_cell_width" type="number" min="10"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Altura (px)</label>
              <input v-model.number="localMap.grid_cell_height" type="number" min="10"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Offsets (Gaps) -->
        <div class="space-y-3">
          <h3 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Deslocamento (Gap)</h3>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Esquerda (px)</label>
              <input v-model.number="localMap.grid_offset_left" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Direita (px)</label>
              <input v-model.number="localMap.grid_offset_right" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Topo (px)</label>
              <input v-model.number="localMap.grid_offset_top" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Base (px)</label>
              <input v-model.number="localMap.grid_offset_bottom" type="number" min="0"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>
          </div>
        </div>

        <!-- Line Settings -->
        <div class="space-y-3">
          <h3 class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Configurações de Linha</h3>

          <div class="space-y-4">
            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Cor</label>
              <div class="flex gap-2">
                <input v-model="localMap.grid_color" type="color"
                  class="h-10 w-20 rounded border border-lumina-border cursor-pointer" />
                <input v-model="localMap.grid_color" type="text"
                  class="flex-1 bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none font-mono" />
              </div>
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Largura (px)</label>
              <input v-model.number="localMap.grid_line_width" type="number" min="1" max="10" step="0.5"
                class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
            </div>

            <div class="space-y-1">
              <label class="text-xs text-lumina-text-muted">Opacidade</label>
              <div class="flex items-center gap-3">
                <input v-model.number="localMap.grid_opacity" type="range" min="0" max="1" step="0.05" class="flex-1" />
                <span class="text-sm font-mono w-12 text-lumina-text">{{ Math.round(localMap.grid_opacity * 100)
                  }}%</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="h-16 shrink-0 border-t border-lumina-border flex items-center justify-end gap-3 px-6">
        <Button @click="$emit('close')" variant="outline" size="sm">
          Cancelar
        </Button>
        <Button @click="handleApply" size="sm">
          Aplicar Alterações
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Button } from '@/components/ui/button'

const props = defineProps({
  isOpen: { type: Boolean, default: false },
  map: { type: Object, required: true }
})

const emit = defineEmits(['update:map', 'close'])

const localMap = ref({ ...props.map })

// Watch for external map changes
watch(() => props.map, (newMap) => {
  localMap.value = { ...newMap }
}, { deep: true })

const handleApply = () => {
  emit('update:map', { ...localMap.value })
  emit('close')
}
</script>
