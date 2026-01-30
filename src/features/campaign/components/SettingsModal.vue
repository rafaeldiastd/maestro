<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
    <div class="bg-lumina-card w-full max-w-sm rounded-xl border border-slate-700 p-6 shadow-2xl">
      <div class="mb-6 flex items-center justify-between">
        <h2 class="text-xl font-semibold text-white">Provedor de Armazenamento</h2>
        <button @click="$emit('close')" class="text-slate-400 hover:text-white">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>

      <div class="space-y-6">
        <p class="text-sm text-slate-400">Selecione qual serviço usar para armazenar imagens. As credenciais são
          carregadas do seu arquivo <code class="bg-slate-800 px-1 rounded">.env</code>.</p>

        <div class="space-y-3">
          <button @click="activeTab = 'supabase'"
            class="w-full flex items-center justify-between p-4 rounded-lg border transition-all"
            :class="activeTab === 'supabase' ? 'border-green-500 bg-slate-800/50' : 'border-slate-700 bg-slate-800 hover:border-slate-500'">
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900 border border-slate-700">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                  stroke="#3ECF8E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path
                    d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z" />
                </svg>
              </div>
              <div class="text-left">
                <div class="font-medium text-white">Supabase</div>
                <div class="text-xs text-slate-400">Armazenamento Padrão</div>
              </div>
            </div>
            <div v-if="activeTab === 'supabase'"
              class="h-4 w-4 rounded-full bg-green-500 shadow-[0_0_10px_rgba(34,197,94,0.5)]"></div>
          </button>

          <button @click="activeTab = 'cloudinary'"
            class="w-full flex items-center justify-between p-4 rounded-lg border transition-all"
            :class="activeTab === 'cloudinary' ? 'border-blue-500 bg-slate-800/50' : 'border-slate-700 bg-slate-800 hover:border-slate-500'">
            <div class="flex items-center gap-3">
              <div class="flex h-10 w-10 items-center justify-center rounded-full bg-slate-900 border border-slate-700">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                  stroke="#3b82f6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M17.5 19c0-1.7-1.3-3-3-3h-11c-1.7 0-3-1.3-3-3s1.3-3 3-3h1" />
                  <path d="M5.5 13c-1.7 0-3-1.3-3-3s1.3-3 3-3 3 1.3 3 3v2" />
                  <path d="M22 10c0-4-3-6-5.5-6C14 4 13 6 13 6c-2.5 0-5.5 2-5.5 6h13c1.5 0 1.5 1.3 1.5 2z" />
                </svg>
              </div>
              <div class="text-left">
                <div class="font-medium text-white">Cloudinary</div>
                <div class="text-xs text-slate-400">Entrega Otimizada</div>
              </div>
            </div>
            <div v-if="activeTab === 'cloudinary'"
              class="h-4 w-4 rounded-full bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,0.5)]"></div>
          </button>
        </div>
      </div>

      <div class="mt-8 flex justify-end">
        <button @click="save"
          class="w-full rounded-lg bg-white py-2.5 text-sm font-bold text-slate-900 hover:bg-slate-200 transition-colors">
          Apply Changes
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useStorage } from '@/composables/useStorage'

const props = defineProps(['isOpen'])
const emit = defineEmits(['close'])

const { providerType, setConfig } = useStorage()

const activeTab = ref('supabase')

onMounted(() => {
  activeTab.value = providerType.value
})

const save = () => {
  const envSupabase = {
    url: import.meta.env.VITE_SUPABASE_URL || '',
    key: import.meta.env.VITE_SUPABASE_ANON_KEY || '',
    bucket: import.meta.env.VITE_SUPABASE_BUCKET || 'images'
  }

  const envCloudinary = {
    cloudName: import.meta.env.VITE_CLOUDINARY_CLOUD_NAME?.trim() || '',
    uploadPreset: import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET?.trim() || '',
    apiKey: import.meta.env.VITE_CLOUDINARY_API_KEY?.trim() || '',
    apiSecret: import.meta.env.VITE_CLOUDINARY_API_SECRET?.trim() || ''
  }

  if (activeTab.value === 'supabase') {
    setConfig('supabase', envSupabase)
    // Clear custom legacy setting to revert to env/default? Or just save overwrite?
    // We save to ensure persistance across reloads
    localStorage.setItem('lumina_supabase_config', JSON.stringify(envSupabase))
  } else {
    setConfig('cloudinary', envCloudinary)
    localStorage.setItem('lumina_cloudinary_config', JSON.stringify(envCloudinary))
  }

  emit('close')
}
</script>
