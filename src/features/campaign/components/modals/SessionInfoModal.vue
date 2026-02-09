<script setup>
import { Info, Calendar, Database } from 'lucide-vue-next'

const props = defineProps({
  sessionName: { type: String, default: '' },
  createdAt: { type: String, default: '' },
  storageProvider: { type: String, default: 'supabase' },
  storageConfig: { type: Object, default: () => ({}) }
})
</script>

<template>
  <div class="space-y-6">

    <!-- Session Name -->
    <div class="space-y-2">
      <div class="flex items-center gap-2 text-lumina-text-muted">
        <Info class="h-4 w-4" />
        <span class="text-xs uppercase tracking-wider font-medium">Nome da Sessão</span>
      </div>
      <h2 class="text-2xl font-bold text-lumina-text font-serif">{{ sessionName || 'Sessão Sem Título' }}</h2>
    </div>

    <!-- Created Date -->
    <div class="space-y-2">
      <div class="flex items-center gap-2 text-lumina-text-muted">
        <Calendar class="h-4 w-4" />
        <span class="text-xs uppercase tracking-wider font-medium">Criado em</span>
      </div>
      <p class="text-sm text-lumina-text">{{ new Date(createdAt).toLocaleDateString('pt-BR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }) }}</p>
    </div>

    <!-- Storage Provider -->
    <div class="space-y-2">
      <div class="flex items-center gap-2 text-lumina-text-muted">
        <Database class="h-4 w-4" />
        <span class="text-xs uppercase tracking-wider font-medium">Provedor de Armazenamento</span>
      </div>
      <div class="flex items-center gap-2">
        <span class="px-2 py-1 rounded-md bg-lumina-bg border border-lumina-border text-xs font-mono text-lumina-text">
          {{ storageProvider }}
        </span>
      </div>

      <!-- Cloudinary Config (if applicable) -->
      <div v-if="storageProvider === 'cloudinary' && storageConfig.cloudName"
        class="mt-3 p-3 rounded-lg bg-lumina-bg/50 border border-lumina-border space-y-2">
        <p class="text-xs text-lumina-text-muted font-medium">Configuração:</p>
        <div class="grid grid-cols-2 gap-2 text-xs">
          <div>
            <span class="text-lumina-text-muted">Cloud Name:</span>
            <span class="ml-2 text-lumina-text font-mono">{{ storageConfig.cloudName }}</span>
          </div>
          <div>
            <span class="text-lumina-text-muted">Preset:</span>
            <span class="ml-2 text-lumina-text font-mono">{{ storageConfig.uploadPreset }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
