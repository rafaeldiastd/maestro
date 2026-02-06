<template>
  <Teleport to="body">
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center bg-background/95 backdrop-blur-md"
      @click.self="$emit('close')">

      <!-- Header / Title -->
      <div v-if="title !== undefined" class="absolute top-4 left-1/2 -translate-x-1/2 z-50">
        <input :value="title" @input="$emit('update:title', $event.target.value)"
          class="bg-transparent text-muted-foreground focus:text-foreground text-center font-serif text-lg font-bold border-b border-transparent focus:border-primary focus:outline-none transition-all px-2 py-1 min-w-[200px]"
          placeholder="Arquivo Sem Título" />
      </div>

      <!-- Close Button -->
      <button @click="$emit('close')"
        class="absolute top-4 right-4 text-muted-foreground hover:text-foreground z-50 p-2 rounded-full hover:bg-muted/20 transition-colors">
        <X class="h-6 w-6" />
      </button>

      <!-- Controls (Footer) -->
      <div v-if="showBroadcast"
        class="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-4 z-50 w-full px-4">

        <!-- Main Reveal Actions -->
        <div class="flex items-center gap-4">
          <button v-if="!isRevealed" @click="handleBroadcast"
            class="rounded-full bg-primary text-primary-foreground px-8 py-3 font-bold shadow-lg transition-transform hover:scale-105 hover:brightness-110 active:scale-95 flex items-center gap-2">
            <Eye class="h-5 w-5" />
            Reveal to All
          </button>
          <button v-else @click="$emit('hide')"
            class="rounded-full bg-destructive text-destructive-foreground px-8 py-3 font-bold shadow-lg backdrop-blur transition-transform hover:scale-105 hover:brightness-110 active:scale-95 flex items-center gap-2">
            <EyeOff class="h-5 w-5" />
            Ocultar de Todos
          </button>
        </div>

        <!-- Granular Controls -->
        <div v-if="isRevealed" class="flex gap-2">
          <button v-if="!isStreamHidden" @click="$emit('hide-stream')"
            class="text-xs font-semibold text-muted-foreground hover:text-foreground bg-card/50 px-4 py-2 rounded-full hover:bg-card transition-colors border border-border flex items-center gap-2">
            <Tv class="h-4 w-4" />
            Ocultar da Stream
          </button>
          <button v-else @click="$emit('show-stream')"
            class="text-xs font-bold text-green-400 hover:text-green-300 bg-green-900/20 px-4 py-2 rounded-full hover:bg-green-900/40 transition-colors border border-green-500/30 flex items-center gap-2">
            <Monitor class="h-4 w-4" />
            Mostrar na Stream
          </button>
        </div>

      </div>

      <!-- Image -->
      <img :src="imageUrl"
        class="max-h-[90vh] max-w-[95vw] object-contain shadow-2xl rounded-sm border border-border/20">

    </div>
  </Teleport>
</template>

<script setup>
import { ref, watch } from 'vue'
import { X, Eye, EyeOff, Tv, Monitor } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

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
