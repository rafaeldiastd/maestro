<script setup>
import { ref, watch, computed } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog'
import { Trash2, Plus, MessageSquare, Dices, FileText } from 'lucide-vue-next'

const props = defineProps({
    open: Boolean,
    system: { type: String, default: 'generic' },
    npc: { type: Object, default: null }
})

const emit = defineEmits(['update:open', 'save', 'open-note'])

const formData = ref({
    name: '',
    description: '',
    // Generic / Common
    hp: '',
    ac: '',
    speed: '',
    challenge_rating: '',
    // D&D 5e Specifics
    stats: {
        str: 10,
        dex: 10,
        con: 10,
        int: 10,
        wis: 10,
        cha: 10
    },
    abilities: [], // Array of { name, description, effect }
    resources: [], // Array of { id, name, current, max }
    note_id: null, // Linked note
    note_tag: '' // Initial tag for creation
})

watch(() => props.open, (newVal) => {
    if (newVal) {
        if (props.npc) {
            const data = JSON.parse(JSON.stringify(props.npc))
            // Ensure abilities array exists
            if (!data.abilities) data.abilities = []
            formData.value = data
        } else {
            // Reset
            formData.value = {
                name: '',
                description: '',
                hp: '',
                ac: '',
                speed: '',
                challenge_rating: '',
                stats: { str: 10, dex: 10, con: 10, int: 10, wis: 10, cha: 10 },
                abilities: [],
                resources: [],
                note_id: null,
                note_tag: ''
            }
        }
    }
})

const addAbility = () => {
    formData.value.abilities.push({
        name: 'New Ability',
        description: '',
        attack_formula: '',
        damage_formula: ''
    })
}

const removeAbility = (index) => {
    formData.value.abilities.splice(index, 1)
}

const handleSave = () => {
    emit('save', { ...formData.value })
    emit('update:open', false)
}

const addResource = () => {
    if (!formData.value.resources) formData.value.resources = []
    formData.value.resources.push({
        id: crypto.randomUUID(),
        name: '',
        current: 1,
        max: 1
    })
}

const removeResource = (index) => {
    formData.value.resources.splice(index, 1)
}

const handleOpenNote = () => {
    // If we have a note_id, pass it. If not, pass null but indicate intention to create for this NPC.
    emit('open-note', props.npc, formData.value.note_tag)
}
</script>

<template>
    <Dialog :open="open" @update:open="$emit('update:open', $event)">
        <DialogContent
            class="sm:max-w-[700px] bg-lumina-card border-lumina-border text-lumina-text max-h-[90vh] overflow-y-auto hidden-scrollbar">
            <DialogHeader>
                <DialogTitle class="font-serif text-xl">{{ npc ? 'Editar NPC' : 'Criar NPC' }}</DialogTitle>
                <DialogDescription class="text-lumina-text-muted">
                    Adicione uma nova criatura ao seu bestiário ({{ system === 'dnd5e' ? 'D&D 5e' : (system === 'pf2e' ?
                    'Pathfinder 2e' : 'Genérico') }}).
                </DialogDescription>
            </DialogHeader>

            <div class="space-y-6 py-4">
                <!-- Basic Info -->
                <div class="grid grid-cols-2 gap-4">
                    <div class="space-y-1.5 col-span-2">
                        <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Nome</Label>
                        <Input v-model="formData.name" placeholder="Goblin" class="bg-lumina-bg border-lumina-border" />
                    </div>
                </div>

                <div class="space-y-1.5">
                    <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Descrição</Label>
                    <Textarea v-model="formData.description" placeholder="A small, greenish creature..."
                        class="bg-lumina-bg border-lumina-border min-h-[80px]" />
                </div>

                <!-- D&D 5e / PF2e Specifics -->
                <div v-if="system === 'dnd5e' || system === 'pf2e'"
                    class="space-y-6 border-t border-lumina-border pt-4">
                    <div class="grid grid-cols-4 gap-3">
                        <div class="space-y-1">
                            <Label class="text-[10px] uppercase text-lumina-text-muted">CA</Label>
                            <Input v-model="formData.ac" placeholder="15"
                                class="bg-lumina-bg border-lumina-border h-8 text-sm" />
                        </div>
                        <div class="space-y-1">
                            <Label class="text-[10px] uppercase text-lumina-text-muted">HP</Label>
                            <Input v-model="formData.hp" placeholder="7 (2d6)"
                                class="bg-lumina-bg border-lumina-border h-8 text-sm" />
                        </div>
                        <div class="space-y-1">
                            <Label class="text-[10px] uppercase text-lumina-text-muted">Deslocamento</Label>
                            <Input v-model="formData.speed" placeholder="30ft"
                                class="bg-lumina-bg border-lumina-border h-8 text-sm" />
                        </div>
                        <div class="space-y-1">
                            <Label class="text-[10px] uppercase text-lumina-text-muted">ND / Nível</Label>
                            <Input v-model="formData.challenge_rating" placeholder="1/4"
                                class="bg-lumina-bg border-lumina-border h-8 text-sm" />
                        </div>
                    </div>

                    <!-- Stats -->
                    <div class="space-y-2">
                        <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Valores de
                            Habilidade</Label>
                        <div class="grid grid-cols-6 gap-2">
                            <div v-for="stat in ['str', 'dex', 'con', 'int', 'wis', 'cha']" :key="stat"
                                class="space-y-1 text-center">
                                <Label class="text-[10px] uppercase text-lumina-text-muted">{{ stat }}</Label>
                                <Input v-model="formData.stats[stat]"
                                    class="bg-lumina-bg border-lumina-border h-8 text-sm text-center px-1" />
                            </div>
                        </div>
                    </div>

                    <!-- Abilities / Actions -->
                    <div class="space-y-3">
                        <div class="flex items-center justify-between border-b border-lumina-border pb-2">
                            <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Ações e
                                Habilidades</Label>
                            <Button size="sm" variant="outline"
                                class="h-6 text-xs gap-1 border-lumina-border hover:bg-lumina-bg" @click="addAbility">
                                <Plus class="h-3 w-3" /> Adicionar
                            </Button>
                        </div>

                        <div v-if="formData.abilities.length === 0"
                            class="text-center py-4 text-lumina-text-muted text-xs italic">
                            Nenhuma habilidade adicionada.
                        </div>

                        <div v-else class="space-y-3">
                            <div v-for="(ability, index) in formData.abilities" :key="index"
                                class="p-3 rounded border border-lumina-border bg-lumina-bg/30 space-y-2">

                                <!-- Name & Delete -->
                                <div class="flex items-center gap-2">
                                    <Input v-model="ability.name" placeholder="Nome da Habilidade (ex: Cimitarra)"
                                        class="h-7 text-xs bg-lumina-bg border-lumina-border font-bold flex-1" />
                                    <Button variant="ghost" size="icon"
                                        class="h-6 w-6 text-lumina-text-muted hover:text-red-400"
                                        @click="removeAbility(index)">
                                        <Trash2 class="h-3 w-3" />
                                    </Button>
                                </div>

                                <!-- Description -->
                                <Textarea v-model="ability.description" placeholder="Descrição..."
                                    class="min-h-[60px] text-xs bg-lumina-bg border-lumina-border" />

                                <!-- Formulas -->
                                <div class="grid grid-cols-2 gap-2">
                                    <div class="space-y-1">
                                        <Label class="text-[10px] text-lumina-text-muted uppercase">Ataque
                                            (1d20+Mod)</Label>
                                        <Input v-model="ability.attack_formula" placeholder="1d20+5"
                                            class="h-7 text-xs bg-lumina-bg border-lumina-border font-mono text-lumina-detail" />
                                    </div>
                                    <div class="space-y-1">
                                        <Label class="text-[10px] text-lumina-text-muted uppercase">Dano
                                            (Dado+Mod)</Label>
                                        <Input v-model="ability.damage_formula" placeholder="1d6+3"
                                            class="h-7 text-xs bg-lumina-bg border-lumina-border font-mono text-red-400" />
                                    </div>
                                </div>

                                <!-- Test Actions (Preview) -->
                                <div
                                    class="flex items-center justify-end gap-1 border-t border-lumina-border/30 pt-2 mt-1">
                                    <span class="text-[10px] text-lumina-text-muted mr-auto italic">Prévia das
                                        Ações:</span>
                                    <Button size="icon" variant="ghost"
                                        class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text"
                                        title="Enviar para Chat">
                                        <MessageSquare class="h-3 w-3" />
                                    </Button>
                                    <Button size="icon" variant="ghost"
                                        class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text"
                                        title="Rolar Dados">
                                        <Dices class="h-3 w-3" />
                                    </Button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Resources Section -->
                <div class="space-y-3 pt-4 border-t border-lumina-border mt-4">
                    <div class="flex items-center justify-between">
                        <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Recursos (Slots,
                            Pontos)</Label>
                        <Button size="sm" variant="outline"
                            class="h-6 text-xs gap-1 border-lumina-border hover:bg-lumina-bg" @click="addResource">
                            <Plus class="h-3 w-3" /> Adicionar
                        </Button>
                    </div>

                    <div class="space-y-2">
                        <div v-for="(res, idx) in formData.resources" :key="idx"
                            class="flex items-center gap-2 p-2 rounded bg-lumina-bg/50 border border-lumina-border">
                            <div class="flex-1 space-y-1">
                                <Input v-model="res.name" placeholder="Nome (ex: Ações Lendárias)"
                                    class="h-7 text-xs bg-lumina-bg border-lumina-border" />
                                <div class="flex items-center gap-2">
                                    <span class="text-[10px] text-lumina-text-muted">Máx:</span>
                                    <Input v-model="res.max" type="number"
                                        class="h-6 w-16 text-xs bg-lumina-bg border-lumina-border"
                                        @input="res.current = res.max" />
                                </div>
                            </div>
                            <Button variant="ghost" size="icon"
                                class="h-6 w-6 text-lumina-text-muted hover:text-red-400" @click="removeResource(idx)">
                                <Trash2 class="h-3 w-3" />
                            </Button>
                        </div>
                    </div>
                </div>

                <!-- Linked Notes -->
                <div v-if="npc" class="border-t border-lumina-border pt-4">
                    <div
                        class="flex items-center justify-between p-3 rounded bg-lumina-bg/20 border border-lumina-border">
                        <div class="flex items-center gap-3">
                            <div
                                class="h-8 w-8 rounded-full bg-lumina-detail/10 flex items-center justify-center text-lumina-detail">
                                <FileText class="h-4 w-4" />
                            </div>
                            <div>
                                <p class="text-sm font-medium text-lumina-text">Notas do Mestre</p>
                                <p class="text-[10px] text-lumina-text-muted">
                                    {{ formData.note_id ? 'Nota vinculada disponível' : 'Nenhuma nota vinculada' }}
                                </p>
                            </div>
                        </div>
                        <div class="flex items-center gap-2">
                            <Input v-if="!formData.note_id" v-model="formData.note_tag" placeholder="Tag (ex: Vilão)"
                                class="h-8 w-32 text-xs bg-lumina-bg border-lumina-border" />
                            <Button variant="outline" size="sm" class="border-lumina-border hover:bg-lumina-bg text-xs"
                                @click="handleOpenNote">
                                {{ formData.note_id ? 'Abrir Nota' : 'Criar e Vincular Nota' }}
                            </Button>
                        </div>
                    </div>
                </div>

            </div>

            <DialogFooter>
                <Button variant="ghost" @click="$emit('update:open', false)">Cancelar</Button>
                <Button @click="handleSave" class="bg-lumina-text text-lumina-bg hover:bg-white">Salvar NPC</Button>
            </DialogFooter>
        </DialogContent>
    </Dialog>
</template>
