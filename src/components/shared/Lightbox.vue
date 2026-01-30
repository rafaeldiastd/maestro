<template>
  <Teleport to="body">
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center bg-black/95 backdrop-blur-md"
      @click.self="$emit('close')">

      <!-- Header / Title -->
      <div v-if="title !== undefined" class="absolute top-4 left-1/2 -translate-x-1/2 z-50">
        <input :value="title" @input="$emit('update:title', $event.target.value)"
          class="bg-transparent text-white/50 text-center font-serif text-lg font-bold border-b border-transparent focus:border-white focus:text-white focus:outline-none transition-all px-2 py-1 min-w-[200px]"
          placeholder="Arquivo Sem Título" />
      </div>

      <!-- Close Button -->
      <button @click="$emit('close')"
        class="absolute top-4 right-4 text-slate-400 hover:text-white z-50 p-2 rounded-full hover:bg-white/10 transition-colors">
        <X class="h-6 w-6" />
      </button>

      <!-- Controls (Footer) -->
      <!-- Controls (Footer) -->
      <div v-if="showBroadcast"
        class="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 z-50 w-full px-4">

        <!-- Main Reveal Actions -->
        <div class="flex items-center gap-4">
          <button v-if="!isRevealed" @click="handleBroadcast"
            class="rounded-full bg-green-500 px-8 py-3 font-bold text-white shadow-lg transition-transform hover:scale-105 hover:bg-green-400 active:scale-95 flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
            Reveal to All
          </button>
          <button v-else @click="$emit('hide')"
            class="rounded-full bg-red-500/80 px-8 py-3 font-bold text-white shadow-lg backdrop-blur transition-transform hover:scale-105 hover:bg-red-500 active:scale-95 flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path
                d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24">
              </path>
              <line x1="1" y1="1" x2="23" y2="23"></line>
            </svg>
            Ocultar de Todos
          </button>
        </div>

        <!-- Granular Controls -->
        <div v-if="isRevealed" class="flex gap-2">
          <button v-if="!isStreamHidden" @click="$emit('hide-stream')"
            class="text-xs font-semibold text-white/80 hover:text-white bg-black/40 px-4 py-2 rounded-full hover:bg-black/60 transition-colors border border-white/10 flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
              <line x1="8" y1="21" x2="16" y2="21"></line>
              <line x1="12" y1="17" x2="12" y2="21"></line>
            </svg>
            Ocultar apenas da Stream
          </button>
          <button v-else @click="$emit('show-stream')"
            class="text-xs font-bold text-green-300 hover:text-green-200 bg-green-900/40 px-4 py-2 rounded-full hover:bg-green-900/60 transition-colors border border-green-500/50 flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
            Mostrar na Stream
          </button>
        </div>

      </div>

      <!-- Image -->
      <img :src="imageUrl" class="max-h-[90vh] max-w-[95vw] object-contain shadow-2xl rounded-sm">

    </div>
  </Teleport>
</template>

<script setup>
import { ref, watch } from 'vue'
import { X } from 'lucide-vue-next'

const props = defineProps({
  isOpen: Boolean,
  imageUrl: String,
  title: String,
  showBroadcast: Boolean,
  isRevealed: Boolean,
  isStreamHidden: Boolean
})

const emit = defineEmits(['close', 'broadcast', 'hide', 'hide-stream', 'show-stream', 'update:title'])
const sent = ref(false)

watch(() => props.isOpen, (val) => {
  if (!val) sent.value = false
})

const handleBroadcast = () => {
  emit('broadcast')
  sent.value = true
  setTimeout(() => sent.value = false, 2000)
}
</script>
