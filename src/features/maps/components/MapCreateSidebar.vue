<template>
  <div class="fixed left-16 top-0 bottom-0 z-40 w-96 bg-card border-r border-border shadow-2xl">
    <div class="h-full flex flex-col">
      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-border flex items-center justify-between px-4 bg-card">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" class="text-lumina-detail">
            <path d="M12 5v14M5 12h14" />
          </svg>
          <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Criar Mapa</span>
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
        <!-- Map Name -->
        <div class="space-y-2">
          <label class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Nome do Mapa</label>
          <input v-model="formData.name" type="text" placeholder="Digite o nome do mapa"
            class="w-full bg-lumina-bg border border-lumina-border rounded px-3 py-2 text-sm text-lumina-text focus:border-lumina-detail focus:outline-none" />
        </div>

        <!-- Background Image -->
        <div class="space-y-2">
          <label class="text-xs font-bold text-lumina-text-muted uppercase tracking-wider">Imagem de Fundo</label>
          <Button @click="$emit('pick-image')" variant="default" size="sm" class="w-full gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2">
              <rect width="18" height="18" x="3" y="3" rx="2" ry="2" />
              <circle cx="9" cy="9" r="2" />
              <path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21" />
            </svg>
            {{ formData.background_url ? 'Alterar Imagem' : 'Selecionar Imagem' }}
          </Button>

          <!-- Image Preview -->
          <div v-if="formData.background_url"
            class="mt-2 aspect-video bg-lumina-bg/50 rounded border border-lumina-border overflow-hidden">
            <img :src="formData.background_url" class="w-full h-full object-cover" alt="Map preview" />
          </div>
          <div v-else
            class="mt-2 aspect-video bg-lumina-bg/50 rounded border border-lumina-border overflow-hidden flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="1" class="text-lumina-text-muted">
              <rect width="18" height="18" x="3" y="3" rx="2" ry="2" />
              <circle cx="9" cy="9" r="2" />
              <path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21" />
            </svg>
          </div>
        </div>

        <!-- Visible to Players Toggle -->
        <div class="flex items-center justify-between p-3 bg-lumina-bg/50 rounded border border-lumina-border">
          <div>
            <span class="text-sm font-bold text-lumina-text">Visível para Jogadores</span>
            <p class="text-xs text-lumina-text-muted mt-0.5">Tornar este mapa visível na visão dos jogadores</p>
          </div>
          <label class="relative inline-flex items-center cursor-pointer">
            <input v-model="formData.is_active" type="checkbox" class="sr-only peer" />
            <div
              class="w-11 h-6 bg-lumina-border peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-lumina-detail">
            </div>
          </label>
        </div>

        <!-- Info Box -->
        <div class="p-3 bg-lumina-detail/10 border border-lumina-detail/30 rounded-lg">
          <div class="flex gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" class="text-lumina-detail shrink-0 mt-0.5">
              <circle cx="12" cy="12" r="10" />
              <path d="M12 16v-4M12 8h.01" />
            </svg>
            <div class="text-xs text-lumina-text-muted">
              <p class="font-bold text-lumina-text mb-1">Configurações da Grade</p>
              <p>A grade será criada com configurações padrão. Você pode personalizá-la depois clicando no botão
                "Configurações" na barra de ferramentas.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="h-16 shrink-0 border-t border-lumina-border flex items-center justify-end gap-3 px-4">
        <Button @click="$emit('close')" variant="outline" size="sm">
          Cancelar
        </Button>
        <Button @click="handleSave" size="sm" :disabled="!formData.name || !formData.background_url">
          Criar Mapa
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Button } from '@/components/ui/button'

const emit = defineEmits(['close', 'save', 'pick-image'])

const formData = ref({
  name: '',
  background_url: '',
  width: 1920,
  height: 1080,
  // Default grid settings
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
  grid_line_width: 1,
  is_active: false
})

const handleSave = () => {
  if (!formData.value.name || !formData.value.background_url) return
  emit('save', { ...formData.value })

  // Reset form
  formData.value = {
    name: '',
    background_url: '',
    width: 1920,
    height: 1080,
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
    grid_line_width: 1,
    is_active: false
  }
}

// Expose method to set background URL from parent
defineExpose({
  setBackgroundUrl: (url) => {
    formData.value.background_url = url
  }
})
</script>
