<script setup>
import { ref, watch, computed } from 'vue'
import { X, Sword, GripVertical, Trash2, Plus, RefreshCw, AlertCircle } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'

const props = defineProps({
    isOpen: Boolean,
    participants: { type: Array, default: () => [] },
    activeParticipantId: Number,
    round: { type: Number, default: 1 },
    isCapturing: Boolean
})

const emit = defineEmits(['close', 'update:participants', 'update:isCapturing', 'next-turn', 'clear', 'update:round'])

const localParticipants = ref([])

// Sync props to local
watch(() => props.participants, (newVal) => {
    localParticipants.value = JSON.parse(JSON.stringify(newVal))
}, { immediate: true, deep: true })

// Emit changes
const save = () => {
    emit('update:participants', localParticipants.value)
}

const addParticipant = () => {
    localParticipants.value.push({
        id: crypto.randomUUID(),
        name: 'Novo Participante',
        total: 0,
        type: 'npc'
    })
    save()
}

const removeParticipant = (id) => {
    localParticipants.value = localParticipants.value.filter(p => p.id !== id)
    save()
}

const sortInitiative = () => {
    localParticipants.value.sort((a, b) => b.total - a.total)
    save()
}

const updateValue = (id, field, value) => {
    const p = localParticipants.value.find(x => x.id === id)
    if (p) {
        p[field] = value
        save()
    }
}

// Drag and Drop
const draggedIndex = ref(null)

const onDragStart = (event, index) => {
    draggedIndex.value = index
    event.dataTransfer.effectAllowed = 'move'
}

const onDrop = (event, dropIndex) => {
    const dragIndex = draggedIndex.value
    if (dragIndex === null || dragIndex === dropIndex) return

    const item = localParticipants.value[dragIndex]
    localParticipants.value.splice(dragIndex, 1)
    localParticipants.value.splice(dropIndex, 0, item)

    draggedIndex.value = null
    save()
}
</script>

<template>
    <div class="h-full flex flex-col bg-lumina-card text-lumina-text border-r border-lumina-border shadow-2xl">
        <!-- Header -->
        <div
            class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-lumina-bg/80 backdrop-blur-md">
            <div class="flex items-center gap-2">
                <Sword class="h-4 w-4 text-lumina-detail" />
                <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Iniciativa</span>
            </div>
            <Button variant="ghost" size="icon"
                class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
                @click="$emit('close')">
                <X class="h-4 w-4" />
            </Button>
        </div>

        <!-- Toolbar -->
        <div class="p-3 border-b border-lumina-border bg-lumina-bg/30 space-y-3">
            <!-- Capture Toggle -->
            <div class="flex flex-col gap-2">
                <Button class="w-full transition-all duration-300 gap-2 font-bold tracking-wide"
                    :class="isCapturing
                        ? 'bg-green-600 hover:bg-green-700 text-white shadow-lg shadow-green-900/20'
                        : 'bg-lumina-bg border border-lumina-border text-lumina-text-muted hover:text-lumina-text hover:border-lumina-text/50'" @click="$emit('update:isCapturing', !isCapturing)">
                    <div v-if="isCapturing" class="flex items-center gap-2">
                        <span class="relative flex h-2 w-2">
                            <span
                                class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                        </span>
                        <span>Capturando Rolagens</span>
                    </div>
                    <div v-else class="flex items-center gap-2">
                        <Sword class="h-4 w-4 opacity-50" />
                        <span>Iniciar Combate</span>
                    </div>
                </Button>

                <p class="text-[10px] text-center text-lumina-text-muted/60 uppercase tracking-widest"
                    v-if="isCapturing">
                    Aguardando rolagens... (/init)
                </p>
            </div>

            <div class="flex gap-2">
                <Button size="sm" variant="outline" class="flex-1 h-7 text-xs border-lumina-border hover:bg-lumina-bg"
                    @click="addParticipant">
                    <Plus class="h-3 w-3 mr-1" /> Add
                </Button>
                <Button size="sm" variant="outline" class="flex-1 h-7 text-xs border-lumina-border hover:bg-lumina-bg"
                    @click="sortInitiative">
                    <RefreshCw class="h-3 w-3 mr-1" /> Ordenar
                </Button>
                <Button size="sm" variant="outline"
                    class="h-7 w-7 p-0 border-lumina-border hover:bg-red-500/10 hover:text-red-400 hover:border-red-500/30"
                    @click="$emit('clear')" title="Limpar">
                    <Trash2 class="h-3 w-3" />
                </Button>
            </div>

            <div class="flex items-center justify-between text-xs font-mono text-lumina-text-muted pt-1">
                <span>Round: {{ round }}</span>
            </div>
        </div>

        <!-- List -->
        <div class="flex-1 overflow-y-auto p-2 space-y-1">
            <div v-if="localParticipants.length === 0"
                class="flex flex-col items-center justify-center h-40 text-lumina-text-muted text-xs text-center p-4 opacity-70">
                <Sword class="h-8 w-8 mb-2 opacity-20" />
                <p>Nenhum participante.</p>
                <p class="mt-1">Role iniciativa no chat ou adicione manualmente.</p>
            </div>

            <div class="space-y-1" @dragover.prevent @drop.prevent>
                <div v-for="(p, index) in localParticipants" :key="p.id" draggable="true"
                    @dragstart="onDragStart($event, index)" @drop="onDrop($event, index)" @dragover.prevent
                    @dragenter.prevent
                    class="group flex items-center gap-2 p-2 rounded border border-lumina-border bg-lumina-bg/40 hover:border-lumina-detail/30 transition-colors cursor-move"
                    :class="{ 'ring-2 ring-lumina-detail bg-lumina-detail/5': index === activeParticipantId, 'opacity-50': draggedIndex === index }">

                    <!-- Drag Handle -->
                    <div class="text-lumina-text-muted hover:text-lumina-text opacity-50">
                        <GripVertical class="h-4 w-4" />
                    </div>

                    <!-- Content -->
                    <div class="flex-1 min-w-0 flex flex-col gap-1">
                        <Input v-model="p.name" @change="save"
                            class="h-6 text-sm bg-transparent border-transparent hover:border-lumina-border focus:border-lumina-detail focus:bg-lumina-bg px-1 py-0" />
                    </div>

                    <!-- Init Value -->
                    <Input type="number" v-model.number="p.total" @change="save"
                        class="w-16 h-8 text-center font-mono font-bold bg-lumina-bg border-lumina-border focus:border-lumina-detail text-lg" />

                    <!-- Delete -->
                    <button
                        class="opacity-0 group-hover:opacity-100 p-1 text-lumina-text-muted hover:text-red-400 transition-all"
                        @click="removeParticipant(p.id)">
                        <X class="h-3 w-3" />
                    </button>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="p-4 border-t border-lumina-border bg-lumina-bg/80">
            <Button class="w-full bg-lumina-text text-lumina-bg hover:bg-white" @click="$emit('next-turn')">
                Próximo Turno
            </Button>
        </div>
    </div>
</template>
