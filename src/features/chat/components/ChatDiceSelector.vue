<script setup>
import { ref } from 'vue'
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { Dices, ChevronDown, Check } from 'lucide-vue-next'

const props = defineProps({
    mode: { type: String, default: 'normal' }
})
const emit = defineEmits(['roll', 'update:mode'])

const setMode = (mode) => {
    emit('update:mode', mode)
}

const handleRoll = (die) => {
    let formula = `1${die}`

    if (rollMode.value === 'advantage') {
        formula = `2${die}kh1`
    } else if (rollMode.value === 'disadvantage') {
        formula = `2${die}kl1`
    }

    emit('roll', formula)
}
</script>

<template>
    <DropdownMenu>
        <DropdownMenuTrigger as-child>
            <Button variant="outline" class="h-8 gap-2 bg-background border-border text-foreground">
                <Dices class="h-4 w-4 text-primary" />
                <span class="text-xs">Rolagens</span>
                <ChevronDown class="h-3 w-3 opacity-50" />
            </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent class="w-56 bg-lumina-card border-lumina-border text-lumina-text p-2 z-[110]" align="end">
            <!-- Modes -->
            <div class="flex p-1 bg-lumina-bg rounded-md mb-2 gap-1">
                <button @click="setMode('normal')" class="flex-1 text-[10px] font-bold py-1 rounded transition-colors"
                    :class="mode === 'normal' ? 'bg-lumina-card text-lumina-text shadow-sm' : 'text-lumina-text-muted hover:text-lumina-text'">
                    Normal
                </button>
                <button @click="setMode('advantage')"
                    class="flex-1 text-[10px] font-bold py-1 rounded transition-colors"
                    :class="mode === 'advantage' ? 'bg-green-900/30 text-green-400 shadow-sm' : 'text-lumina-text-muted hover:text-green-400'">
                    Vantagem
                </button>
                <button @click="setMode('disadvantage')"
                    class="flex-1 text-[10px] font-bold py-1 rounded transition-colors"
                    :class="mode === 'disadvantage' ? 'bg-red-900/30 text-red-400 shadow-sm' : 'text-lumina-text-muted hover:text-red-400'">
                    Desv.
                </button>
            </div>

            <div class="grid grid-cols-4 gap-2">
                <Button v-for="die in ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100']" :key="die" variant="ghost"
                    size="sm"
                    class="h-8 text-xs font-mono border border-lumina-border/50 hover:bg-lumina-bg/50 hover:text-lumina-detail hover:border-lumina-detail"
                    @click="handleRoll(die)">
                    {{ die }}
                </Button>
            </div>
        </DropdownMenuContent>
    </DropdownMenu>
</template>
