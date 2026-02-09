<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
    <div class="bg-lumina-card w-full max-w-md rounded-xl border border-slate-700 p-6 shadow-2xl">
      <div class="mb-4 flex items-center justify-between">
        <h2 class="text-xl font-semibold text-stone-200">Sessão Criada!</h2>
        <button @click="$emit('close')" class="text-slate-400 hover:text-white">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>

      <div class="space-y-4">
        <p class="text-slate-300">Compartilhe este link com seus jogadores:</p>
        <div class="flex gap-2">
          <input :value="link" readonly @click="$event.target.select()"
            class="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-white outline-none">
          <button @click="copy"
            class="rounded-lg bg-stone-100 px-4 py-2 font-medium text-stone-900 hover:bg-white border border-stone-200">
            {{ copied ? 'Copiado!' : 'Copiar' }}
          </button>
        </div>
        <p class="text-xs text-slate-500">Imagens carregadas. Clique em uma imagem e use "Transmitir" para mostrar aos
          jogadores.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps(['isOpen', 'link'])
defineEmits(['close'])

const copied = ref(false)

const copy = () => {
  navigator.clipboard.writeText(props.link)
  copied.value = true
  setTimeout(() => copied.value = false, 2000)
}
</script>
