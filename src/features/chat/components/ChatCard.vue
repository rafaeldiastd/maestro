<script setup>
import { computed } from 'vue'
import { Flame, Star, Sparkles, Sword, Shield, Scroll, Crown } from 'lucide-vue-next'

const props = defineProps({
    card: { type: Object, required: true }
    // expected: type='card', subtype='spell|ability|feature', title, description, properties: {}
})

const iconMap = {
    attack: Sword,
    spell: Sparkles,
    ability: Star,
    feature: Crown,
    item: Scroll,
    damage: Flame,
    defense: Shield
}

const subtype = computed(() => props.card.subtype || 'ability')
const Icon = computed(() => iconMap[subtype.value] || Star)

const themeClasses = computed(() => {
    switch (subtype.value) {
        case 'attack': return 'border-red-500/30 bg-red-950/20'
        case 'spell': return 'border-blue-500/30 bg-blue-950/20'
        case 'feature': return 'border-amber-500/30 bg-amber-950/20'
        case 'item': return 'border-emerald-500/30 bg-emerald-950/20'
        default: return 'border-border bg-card'
    }
})

const titleColor = computed(() => {
    switch (subtype.value) {
        case 'attack': return 'text-red-400'
        case 'spell': return 'text-blue-400'
        case 'feature': return 'text-amber-400'
        case 'item': return 'text-emerald-400'
        default: return 'text-foreground'
    }
})

</script>

<template>
    <div class="flex flex-col items-center justify-center w-full mt-1 select-none">
        <!-- Title -->
        <div class="flex items-center gap-2 mb-3">
            <component :is="Icon" class="h-4 w-4" :class="titleColor" />
            <span class="font-bold text-base font-serif tracking-wide" :class="titleColor">{{ card.title }}</span>
        </div>

        <!-- Properties (if any) -->
        <div v-if="card.properties && Object.keys(card.properties).length > 0"
            class="flex flex-wrap items-center justify-center gap-x-4 gap-y-1 mb-3 text-[10px] text-muted-foreground font-mono border-y border-border/30 py-1 w-full">
            <div v-for="(val, key) in card.properties" :key="key" class="flex gap-1">
                <span class="uppercase opacity-60">{{ key }}:</span>
                <span class="text-foreground opacity-90">{{ val }}</span>
            </div>
        </div>

        <!-- Body -->
        <div class="text-sm text-foreground leading-relaxed whitespace-pre-wrap text-center opacity-90 px-2 font-sans">
            {{ card.description }}
        </div>
    </div>
</template>
