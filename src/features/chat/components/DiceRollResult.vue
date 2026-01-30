<script setup>
import { Button } from '@/components/ui/button'

const props = defineProps({
  result: { type: Object, required: true }
})

const emit = defineEmits(['roll-damage'])
</script>

<template>
  <div class="flex items-center justify-evenly w-full py-2">

    <!-- Big Number -->
    <div class="text-lumina-detail text-4xl font-serif font-medium leading-none mb-4 drop-shadow-md">
      {{ result.total }}
    </div>

    <div class="flex flex-col">
      <!-- Title / Label -->
      <h3 class="text-lumina-text font-serif font-bold text-md tracking-wide">
        {{ result.label || 'Rolagem' }}
      </h3>

      <!-- Formula Breakdown -->
      <div class="text-lumina-text-muted font-mono text-xs tracking-wider opacity-60">
        {{ result.output }}
      </div>
    </div>
  </div>


  <!-- Follow-up Actions -->
  <div v-if="result.damageFormula" class="mt-3 pt-3 border-t border-lumina-border/30 w-full flex justify-center">
    <Button size="full" variant="ghost"
      class="h-7 text-xs bg-red-900/20 hover:bg-red-900/40 text-red-300 gap-1.5 border border-red-500/20 transition-all hover:scale-105"
      @click.stop="$emit('roll-damage', result.damageFormula)">
      <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
        class="lucide lucide-dices">
        <rect width="12" height="12" x="2" y="10" rx="2" ry="2" />
        <path d="m17.92 14 3.5-3.5a2.24 2.24 0 0 0 0-3l-5-4.92a2.24 2.24 0 0 0-3 0L10 6" />
        <path d="M6 18h.01" />
        <path d="M10 14h.01" />
        <path d="M15 6h.01" />
        <path d="M18 9h.01" />
      </svg>
      Rolar Dano
    </Button>
  </div>

</template>
