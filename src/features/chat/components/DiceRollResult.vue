<script setup>
import { computed } from 'vue'
import { Button } from '@/components/ui/button'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'

const props = defineProps({
  result: { type: Object, required: true }
})

const emit = defineEmits(['roll-damage'])

const displayLabel = computed(() => {
  if (!props.result.label) return 'Rolagem'
  if (props.result.label.includes(' - ')) {
    return props.result.label.split(' - ').slice(1).join(' - ')
  }
  return props.result.label
})

// Advantage/Disadvantage Logic
const isAdvantage = computed(() => (props.result.originalFormula || props.result.formula).includes('kh1'))
const isDisadvantage = computed(() => (props.result.originalFormula || props.result.formula).includes('kl1'))

const dualRolls = computed(() => {
  if (!isAdvantage.value && !isDisadvantage.value) return null

  try {
    // Structure for 2d20kh1: result.rolls[0] is the DiceRoll object
    // It contains .rolls array with the individual results.
    // Each result object has { value, useInTotal, ... }
    // Note: useDiceRoll returns .rolls as the top level rolls array from rpg-dice-roller result.
    // The structure typically is: result.rolls[0] -> DieRoll (e.g. 2d20) -> .rolls -> [ {value: 15, ...}, {value: 3, ...} ]

    const group = props.result.rolls[0]
    if (!group || !group.rolls) return null

    return group.rolls.map(r => ({
      value: r.value,
      ignored: !r.useInTotal, // rpg-dice-roller marks used dice
      isCrit: r.value === 20,
      isFumble: r.value === 1
    }))
  } catch (e) {
    console.error('Error parsing dual rolls', e)
    return null
  }
})
</script>

<template>
  <TooltipProvider :delayDuration="1000">
    <Tooltip>
      <TooltipTrigger as-child>
        <div class="flex items-center justify-between w-full py-1 gap-3 cursor-help">

          <!-- Left: Label and Formula -->
          <div class="flex flex-col flex-1 min-w-0">
            <h3 class="text-lumina-text font-serif font-bold text-sm tracking-wide truncate">
              {{ displayLabel }} <span v-if="isAdvantage"
                class="text-green-400 text-[10px] ml-1 uppercase">(Vantagem)</span>
              <span v-if="isDisadvantage" class="text-red-400 text-[10px] ml-1 uppercase">(Desvantagem)</span>
            </h3>

            <div
              class="text-lumina-text-muted font-mono text-[0.625rem] tracking-wider opacity-70 whitespace-normal break-words leading-tight">
              {{ result.output }}
            </div>
          </div>

          <!-- Dual Display (Adv/Dis) -->
          <div v-if="dualRolls" class="flex gap-2">
            <div v-for="(die, idx) in dualRolls" :key="idx"
              class="flex items-center justify-center h-10 w-10 shrink-0 rounded border transition-all" :class="[
                die.ignored ? 'bg-lumina-bg/10 border-lumina-border/20 opacity-40 grayscale scale-90' : 'bg-lumina-bg/30 border-lumina-border/50 scale-100 shadow-md',
                die.isCrit && !die.ignored ? 'text-green-400 border-green-500/50' : '',
                die.isFumble && !die.ignored ? 'text-red-400 border-red-500/50' : '',
                !die.isCrit && !die.isFumble && !die.ignored ? 'text-lumina-detail' : 'text-lumina-text-muted'
              ]">
              <span class="font-serif font-bold text-lg" :class="{ 'line-through': die.ignored }">{{ die.value }}</span>
            </div>
          </div>

          <!-- Right: Big Number (Standard) -->
          <div v-else
            class="flex items-center justify-center h-12 w-14 shrink-0 bg-lumina-bg/30 rounded border border-lumina-border/30">
            <span class="text-lumina-detail text-2xl font-serif font-bold leading-none drop-shadow-sm">
              {{ result.total }}
            </span>
          </div>

        </div>
      </TooltipTrigger>
      <!-- ... tooltip content ... -->
      <TooltipContent class="z-[200] bg-lumina-card border-lumina-border text-lumina-text">
        <p class="font-mono text-xs"><span class="font-bold text-lumina-text-muted">Fórmula:</span> {{
          result.originalFormula || result.formula }}</p>
      </TooltipContent>
    </Tooltip>
  </TooltipProvider>


  <!-- Follow-up Actions -->
  <div v-if="result.damageFormula" class="mt-3 pt-3 border-t border-lumina-border/30 w-full flex justify-center">
    <Button size="full" variant="ghost"
      class="h-7 text-xs bg-red-900/20 hover:bg-red-900/40 text-red-300 gap-1.5 border border-red-500/20 transition-all hover:scale-105"
      @click.stop="$emit('roll-damage', result.originalDamageFormula || result.damageFormula)">
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
