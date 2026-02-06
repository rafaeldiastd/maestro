<script setup>
import { ref, watch } from 'vue'
import { watchDebounced } from '@vueuse/core'
import { X, Pencil, FileText, Shield, Zap, Skull, Heart, Dices, MessageSquare, Plus, Minus, RotateCcw, Timer } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

const props = defineProps({
    npc: { type: Object, required: true },
    system: { type: String, default: 'generic' }
})

const emit = defineEmits(['close', 'edit', 'open-note', 'save', 'roll', 'chat'])

const currentHp = ref(props.npc.hp)
const currentResources = ref(JSON.parse(JSON.stringify(props.npc.resources || [])))

// Sync prop change
watch(() => props.npc, (newNpc) => {
    currentHp.value = newNpc.hp
    currentResources.value = JSON.parse(JSON.stringify(newNpc.resources || []))
})

// Auto-save HP
watchDebounced(currentHp, (val) => {
    if (val !== props.npc.hp) {
        emit('save', { ...props.npc, hp: val })
    }
}, { debounce: 800 })

// Auto-save Resources
watchDebounced(currentResources, (val) => {
    emit('save', { ...props.npc, resources: val })
}, { debounce: 800, deep: true })

const updateResource = (idx, delta) => {
    const res = currentResources.value[idx]
    if (!res) return
    const newVal = parseInt(res.current) + delta
    if (newVal >= 0 && newVal <= res.max) {
        res.current = newVal
    }
}

// Helpers
const calculateModifier = (val) => Math.floor((val - 10) / 2)

const formatModifier = (val) => {
    const mod = calculateModifier(val)
    return mod >= 0 ? `+${mod}` : `${mod}`
}

const rollStat = (stat, val) => {
    const mod = calculateModifier(val)
    const formula = `1d20 + ${mod}`
    emit('roll', {
        name: `${props.npc.name} - ${stat.toUpperCase()} Teste`,
        formula: formula,
        context: 'generic'
    })
}

const rollInitiative = () => {
    if (!props.npc.stats?.dex) return
    const mod = calculateModifier(props.npc.stats.dex)
    const formula = `1d20 + ${mod}`
    emit('roll', {
        name: `${props.npc.name} - Iniciativa`,
        formula: formula,
        context: 'initiative'
    })
}

const rollAbility = (ability) => {
    emit('roll', {
        ...ability,
        name: `${props.npc.name} - ${ability.name}`
    })
}

</script>

<template>
    <div
        class="flex flex-col h-full bg-lumina-card text-lumina-text border-l border-lumina-border shadow-2xl overflow-hidden">
        <!-- Header -->
        <div class="shrink-0 p-4 border-b border-lumina-border bg-lumina-bg/50 flex items-start justify-between">
            <div>
                <h2 class="text-xl font-bold font-serif text-lumina-text leading-tight">{{ npc.name }}</h2>
                <div class="flex items-center gap-2 mt-1">
                    <span
                        class="text-xs px-2 py-0.5 rounded-full bg-lumina-detail/10 text-lumina-detail border border-lumina-detail/20 uppercase tracking-wider font-bold">
                        {{ npc.type || 'NPC' }}
                    </span>
                    <span v-if="npc.challenge_rating" class="text-xs text-lumina-text-muted">
                        CR {{ npc.challenge_rating }}
                    </span>
                </div>
            </div>
            <div class="flex items-center gap-1">
                <Button size="icon" variant="ghost" class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text"
                    @click="$emit('edit', npc)" title="Editar NPC">
                    <Pencil class="h-4 w-4" />
                </Button>
                <Button size="icon" variant="ghost" class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text"
                    @click="$emit('close')">
                    <X class="h-4 w-4" />
                </Button>
            </div>
        </div>

        <!-- Scrollable Content -->
        <div class="flex-1 overflow-y-auto p-4 space-y-6 scrollbar-thin">

            <!-- HP & Stats Row -->
            <div class="grid grid-cols-2 gap-4">
                <div class="bg-lumina-bg/30 rounded-lg p-3 border border-lumina-border">
                    <div
                        class="flex items-center gap-2 mb-1 text-lumina-text-muted text-xs uppercase font-bold tracking-wider">
                        <Heart class="h-3 w-3" /> Pontos de Vida
                    </div>
                    <Input v-model="currentHp"
                        class="h-9 text-lg font-bold bg-lumina-bg border-lumina-border text-center" placeholder="PV" />
                </div>
                <div
                    class="bg-lumina-bg/30 rounded-lg p-3 border border-lumina-border flex flex-col justify-center gap-2">
                    <!-- AC & Speed Block -->
                    <div class="flex items-center justify-between">
                        <span class="text-xs text-lumina-text-muted uppercase font-bold flex items-center gap-1">
                            <Shield class="h-3 w-3" /> CA
                        </span>
                        <span class="text-lg font-bold">{{ npc.ac || '-' }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="text-xs text-lumina-text-muted uppercase font-bold flex items-center gap-1">
                            <Zap class="h-3 w-3" /> Desl
                        </span>
                        <span class="text-sm font-medium">{{ npc.speed || '-' }}</span>
                    </div>
                    <!-- Initiative Block -->
                    <div v-if="(system === 'dnd5e' || system === 'pf2e') && npc.stats?.dex"
                        class="flex items-center justify-between pt-2 border-t border-lumina-border/50 cursor-pointer hover:text-lumina-detail transition-colors group"
                        @click="rollInitiative">
                        <span
                            class="text-xs text-lumina-text-muted group-hover:text-lumina-detail uppercase font-bold flex items-center gap-1">
                            <Timer class="h-3 w-3" /> Inic
                        </span>
                        <span class="text-sm font-bold flex items-center gap-1">
                            {{ formatModifier(npc.stats.dex) }}
                            <Dices class="h-3 w-3 opacity-0 group-hover:opacity-100 transition-opacity" />
                        </span>
                    </div>
                </div>
            </div>

            <!-- Ability Scores (D&D/PF2e) -->
            <div v-if="(system === 'dnd5e' || system === 'pf2e') && npc.stats"
                class="grid grid-cols-6 gap-2 text-center">
                <div v-for="(val, stat) in npc.stats" :key="stat"
                    class="flex flex-col bg-lumina-bg/20 p-2 rounded border border-lumina-border cursor-pointer hover:border-lumina-detail/50 hover:bg-lumina-detail/5 transition-all group relative"
                    @click="rollStat(stat, val)" title="Rolar Teste">
                    <span
                        class="text-[9px] uppercase font-bold text-lumina-text-muted group-hover:text-lumina-detail">{{
                            stat }}</span>
                    <span class="text-sm font-bold text-lumina-text">{{ val }}</span>
                    <span class="text-[9px] text-lumina-text-muted font-mono">
                        {{ formatModifier(val) }}
                    </span>
                </div>
            </div>

            <!-- Description -->
            <div v-if="npc.description"
                class="prose prose-invert prose-sm max-w-none text-lumina-text-muted text-sm leading-relaxed">
                {{ npc.description }}
            </div>

            <!-- Abilities / Actions -->
            <div v-if="npc.abilities && npc.abilities.length > 0" class="space-y-3">
                <h3
                    class="text-xs font-bold uppercase tracking-wider text-lumina-detail border-b border-lumina-border pb-1">
                    Ações & Habilidades</h3>
                <div v-for="(ability, idx) in npc.abilities" :key="idx" class="group relative">
                    <div class="flex items-baseline justify-between mb-1 pr-16 flex-wrap gap-y-1">
                        <div class="flex flex-col gap-2">
                            <span class="font-bold text-sm text-lumina-text">{{ ability.name }}</span>

                            <div class="flex gap-2">
                                <!-- Attack Badge -->
                                <span v-if="ability.attack_formula"
                                    class="font-mono text-[10px] text-lumina-bg bg-lumina-detail px-1.5 py-0.5 rounded font-bold whitespace-nowrap"
                                    title="Rolagem de Ataque">
                                    Atq: {{ ability.attack_formula }}
                                </span>

                                <!-- Damage Badge -->
                                <span v-if="ability.damage_formula"
                                    class="font-mono text-[10px] text-destructive-foreground bg-destructive border border-destructive/30 px-1.5 py-0.5 rounded whitespace-nowrap"
                                    title="Rolagem de Dano">
                                    Dano: {{ ability.damage_formula }}
                                </span>
                            </div>
                        </div>

                        <!-- Legacy Support -->
                        <span v-if="ability.effect && !ability.attack_formula"
                            class="font-mono text-xs text-lumina-detail bg-lumina-detail/10 px-1.5 py-0.5 rounded">
                            {{ ability.effect }}
                        </span>
                    </div>
                    <p class="text-sm text-lumina-text-muted">{{ ability.description }}</p>

                    <!-- Hover Actions -->
                    <div class="absolute top-0 right-0 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
                        <Button size="icon" variant="ghost"
                            class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text" title="Enviar para Chat"
                            @click="$emit('chat', ability)">
                            <MessageSquare class="h-3 w-3" />
                        </Button>
                        <Button size="icon" variant="ghost"
                            class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text" title="Rolar"
                            @click="rollAbility(ability)">
                            <Dices class="h-3 w-3" />
                        </Button>
                    </div>
                </div>
            </div>

            <!-- Resources Section -->
            <div v-if="currentResources && currentResources.length > 0"
                class="space-y-3 pt-4 border-t border-lumina-border">
                <h3 class="text-xs font-bold uppercase tracking-wider text-lumina-detail pb-1">Recursos</h3>
                <div v-for="(res, idx) in currentResources" :key="idx"
                    class="flex items-center justify-between bg-lumina-bg/30 p-2 rounded border border-lumina-border">
                    <span class="text-sm font-bold text-lumina-text">{{ res.name }}</span>
                    <div class="flex items-center gap-2 bg-lumina-bg rounded p-0.5 border border-lumina-border">
                        <button
                            class="h-6 w-6 flex items-center justify-center hover:bg-lumina-detail/20 text-lumina-text rounded"
                            @click="updateResource(idx, -1)">
                            <Minus class="h-3 w-3" />
                        </button>
                        <span class="text-sm font-mono w-8 text-center">{{ res.current }}<span
                                class="text-lumina-text-muted text-[10px]">/{{ res.max }}</span></span>
                        <button
                            class="h-6 w-6 flex items-center justify-center hover:bg-lumina-detail/20 text-lumina-text rounded"
                            @click="updateResource(idx, 1)">
                            <Plus class="h-3 w-3" />
                        </button>
                    </div>
                </div>
            </div>
            <div v-else
                class="text-center py-4 border border-dashed border-lumina-border rounded-lg text-lumina-text-muted text-xs">
                Nenhuma habilidade definida.
                <button class="underline hover:text-lumina-detail ml-1" @click="$emit('edit', npc)">Adicionar</button>
            </div>

            <!-- Notes Link -->
            <div class="pt-4 border-t border-lumina-border">
                <Button variant="outline"
                    class="w-full gap-2 border-lumina-border hover:bg-lumina-bg hover:text-lumina-detail transition-colors"
                    @click="$emit('open-note', npc)">
                    <FileText class="h-4 w-4" />
                    {{ npc.note_id ? 'Abrir Nota Vinculada' : 'Criar Nota' }}
                </Button>
            </div>

        </div>
    </div>
</template>
