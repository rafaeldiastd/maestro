<template>
    <div class="flex flex-col h-full bg-lumina-card text-lumina-text overflow-hidden relative"
        v-if="character && template">

        <!-- Header / Top Bar -->
        <div class="shrink-0 p-4 border-b border-lumina-border bg-lumina-bg/50 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div
                    class="h-10 w-10 rounded-full bg-lumina-detail/20 flex items-center justify-center border border-lumina-detail/30">
                    <span class="font-serif font-bold text-lumina-detail text-lg">{{
                        character.name.charAt(0).toUpperCase() }}</span>
                </div>
                <div>
                    <h2 class="text-xl font-bold font-serif text-lumina-text leading-tight">{{ character.name }}</h2>
                    <p class="text-xs text-lumina-text-muted">{{ template.name }}</p>
                </div>
            </div>
            <div class="flex items-center gap-1">
                <Button variant="ghost" size="icon" @click="$emit('close')">
                    <X class="h-5 w-5" />
                </Button>
            </div>
        </div>

        <!-- Tabs -->
        <div
            class="shrink-0 flex items-center px-4 border-b border-lumina-border bg-lumina-card/80 overflow-x-auto scrollbar-hide">
            <button v-for="tab in template.schema.tabs" :key="tab.id"
                class="px-4 py-3 text-sm font-medium border-b-2 transition-colors whitespace-nowrap"
                :class="activeTab === tab.id ? 'border-lumina-detail text-lumina-detail' : 'border-transparent text-lumina-text-muted hover:text-lumina-text'"
                @click="activeTab = tab.id">
                {{ tab.label }}
            </button>
        </div>

        <!-- Content Area -->
        <div class="flex-1 overflow-y-auto p-6 scrollbar-thin">

            <!-- Main Tab (Standard D&D 5e-ish layout) -->
            <div v-if="activeTab === 'main'" class="space-y-6 max-w-4xl mx-auto">

                <!-- Stats Row (HP, AC, Speed) -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div v-for="stat in template.schema.stats" :key="stat.key"
                        class="bg-lumina-bg/40 border border-lumina-border rounded-lg p-3 text-center flex flex-col items-center justify-center relative group">

                        <span class="text-xs uppercase font-bold text-lumina-text-muted mb-1 tracking-wider">{{
                            stat.label }}</span>

                        <!-- Current/Max Type -->
                        <div v-if="stat.type === 'current_max'" class="flex items-center gap-1">
                            <input type="number" v-model.number="localData[stat.key].current"
                                class="w-12 h-10 text-xl font-bold text-center bg-transparent border-b border-lumina-border focus:border-lumina-detail focus:outline-none" />
                            <span class="text-lumina-text-muted">/</span>
                            <input type="number" v-model.number="localData[stat.key].max"
                                class="w-12 h-10 text-xl font-bold text-center bg-transparent text-lumina-text-muted bg-none border-b border-transparent focus:border-lumina-detail focus:outline-none" />
                        </div>

                        <!-- Number Type -->
                        <div v-else-if="stat.type === 'number'" class="relative">
                            <input type="number" v-model.number="localData[stat.key]"
                                class="w-16 h-10 text-2xl font-bold text-center bg-transparent border-b border-transparent hover:border-lumina-border focus:border-lumina-detail focus:outline-none transition-colors" />
                            <Monitor v-if="stat.key === 'ac'"
                                class="h-4 w-4 absolute -top-1 -right-4 text-lumina-text-muted opacity-20" />
                        </div>

                        <!-- Bonus Type (Initiative) -->
                        <div v-else-if="stat.type === 'bonus'" class="relative">
                            <div class="text-2xl font-bold flex items-center justify-center gap-1 cursor-pointer hover:text-lumina-detail"
                                @click="rollStat(stat.label, localData[stat.key])">
                                {{ formatModifier(localData[stat.key]) }}
                                <Dices class="h-4 w-4 opacity-50" />
                            </div>
                        </div>

                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

                    <!-- Attributes Column -->
                    <div class="space-y-3">
                        <h3 class="text-sm font-bold font-serif text-lumina-detail border-b border-lumina-border pb-1">
                            Atributos</h3>
                        <div class="space-y-2">
                            <div v-for="attr in template.schema.attributes" :key="attr.key"
                                class="bg-lumina-bg/30 border border-lumina-border rounded p-2 flex items-center justify-between group hover:border-lumina-detail/50 transition-colors">

                                <div class="flex flex-col items-center w-12 shrink-0">
                                    <span class="text-[10px] uppercase font-bold text-lumina-text-muted">{{ attr.key
                                        }}</span>
                                    <span class="text-lg font-bold">{{ calculateModifier(localData.attributes[attr.key])
                                        }}</span>
                                </div>

                                <div class="flex-1 text-center px-2">
                                    <span class="font-bold text-sm block">{{ attr.label }}</span>
                                    <button
                                        class="text-xs text-lumina-text-muted hover:text-lumina-detail flex items-center justify-center gap-1 w-full mt-1"
                                        @click="rollAttribute(attr)">
                                        <Dices class="h-3 w-3" /> Rolar
                                    </button>
                                </div>

                                <div class="w-12 text-center border-l border-lumina-border pl-2">
                                    <input type="number" v-model.number="localData.attributes[attr.key]"
                                        class="w-full bg-transparent text-center font-bold text-lumina-text-muted focus:text-lumina-text focus:outline-none" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Skills Column -->
                    <div class="md:col-span-2 space-y-3">
                        <h3 class="text-sm font-bold font-serif text-lumina-detail border-b border-lumina-border pb-1">
                            Perícias</h3>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-1">
                            <div v-for="skill in template.schema.skills" :key="skill.key"
                                class="flex items-center justify-between text-sm py-1 px-2 rounded hover:bg-lumina-bg/50 cursor-pointer group"
                                @click="rollSkill(skill)">
                                <div class="flex items-center gap-2">
                                    <span class="text-lumina-text-muted font-mono text-xs w-6 text-right">
                                        {{ calculateSkillModifier(skill) }}
                                    </span>
                                    <span class="group-hover:text-lumina-detail transition-colors">{{ skill.label
                                        }}</span>
                                    <span class="text-[10px] text-lumina-text-muted uppercase">({{ skill.attr }})</span>
                                </div>
                                <Dices class="h-3 w-3 opacity-0 group-hover:opacity-100 text-lumina-text-muted" />
                            </div>
                        </div>
                    </div>

                </div>

            </div>

            <!-- Other Tabs (Placeholder) -->
            <div v-else class="flex flex-col items-center justify-center h-64 text-lumina-text-muted">
                <Wrench class="h-8 w-8 mb-2 opacity-50" />
                <p>Aba <strong>{{ activeTab }}</strong> em construção.</p>
            </div>

        </div>
    </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { watchDebounced } from '@vueuse/core'
import { X, Dices, Shield, Zap, Heart, Wrench, Monitor } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

const props = defineProps({
    character: Object,
    template: Object
})

const emit = defineEmits(['close', 'update', 'roll'])

const localData = ref(null)
const activeTab = ref('main')

// Initialize Local Data
watch(() => props.character, (newVal) => {
    if (newVal && newVal.data) {
        // Deep copy to avoid mutating prop directly
        localData.value = JSON.parse(JSON.stringify(newVal.data))
    }
}, { immediate: true, deep: true })

// Auto-Save
watchDebounced(localData, (val) => {
    if (!val) return
    emit('update', { ...props.character, data: val })
}, { debounce: 1000, deep: true })


// --- Mechanics Helpers (D&D 5e Logic) ---
// In a fully generic system, these formulas would come from `template.schema.formulas` using `eval` or a parser.
// For now, we hardcode D&D logic as per the "system_key" check or just assumption.

const calculateModifier = (score) => {
    if (score === undefined || score === null) return 0
    return Math.floor((score - 10) / 2)
}

const formatModifier = (val) => {
    return val >= 0 ? `+${val}` : `${val}`
}

const calculateSkillModifier = (skill) => {
    // Basic: just the attribute modifier. 
    // Future: Add proficiency checkbox support in data.
    const attrKey = skill.attr
    const score = localData.value.attributes?.[attrKey] ?? 10
    const mod = calculateModifier(score)
    return mod >= 0 ? `+${mod}` : `${mod}`
}

// --- Roll Handlers ---
const rollAttribute = (attr) => {
    const score = localData.value.attributes?.[attr.key] ?? 10
    const mod = calculateModifier(score)
    const formula = `1d20 ${mod >= 0 ? '+' : ''} ${mod}`

    emit('roll', {
        name: `Teste de ${attr.label}`,
        formula: formula
    })
}

const rollSkill = (skill) => {
    const attrKey = skill.attr
    const score = localData.value.attributes?.[attrKey] ?? 10
    const mod = calculateModifier(score)
    const formula = `1d20 ${mod >= 0 ? '+' : ''} ${mod}`

    emit('roll', {
        name: `Teste de ${skill.label}`,
        formula: formula
    })
}

const rollStat = (label, bonus) => {
    const formula = `1d20 ${bonus >= 0 ? '+' : ''} ${bonus}`
    emit('roll', {
        name: label,
        formula: formula
    })
}

</script>
