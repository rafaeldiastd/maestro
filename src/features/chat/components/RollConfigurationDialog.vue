<script setup>
import { ref } from 'vue'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'

const props = defineProps({
    open: { type: Boolean, required: true },
    title: { type: String, default: 'Confirmar Rolagem' }
})

const emit = defineEmits(['update:open', 'confirm'])

const mode = ref('normal') // normal, advantage, disadvantage

const handleConfirm = () => {
    emit('confirm', mode.value)
    emit('update:open', false)
    mode.value = 'normal' // Reset
}
</script>

<template>
    <Dialog :open="open" @update:open="$emit('update:open', $event)">
        <DialogContent class="sm:max-w-[425px] bg-lumina-card border-lumina-border text-lumina-text">
            <DialogHeader>
                <DialogTitle>{{ title }}</DialogTitle>
                <DialogDescription>
                    Escolha o modo de rolagem para esta ação.
                </DialogDescription>
            </DialogHeader>

            <div class="grid grid-cols-3 gap-4 py-4">
                <Button variant="outline" class="h-20 flex flex-col gap-2 transition-all"
                    :class="mode === 'normal' ? 'border-lumina-detail bg-lumina-detail/10 ring-2 ring-lumina-detail/20' : 'hover:bg-lumina-bg'"
                    @click="mode = 'normal'">
                    <span class="text-lg font-bold">Normal</span>
                    <span class="text-xs text-muted-foreground">1d20</span>
                </Button>

                <Button variant="outline" class="h-20 flex flex-col gap-2 transition-all"
                    :class="mode === 'advantage' ? 'border-green-500 bg-green-500/10 ring-2 ring-green-500/20' : 'hover:bg-green-500/10'"
                    @click="mode = 'advantage'">
                    <span class="text-lg font-bold text-green-500">Vantagem</span>
                    <span class="text-xs text-green-500/70">2d20 (Maior)</span>
                </Button>

                <Button variant="outline" class="h-20 flex flex-col gap-2 transition-all"
                    :class="mode === 'disadvantage' ? 'border-red-500 bg-red-500/10 ring-2 ring-red-500/20' : 'hover:bg-red-500/10'"
                    @click="mode = 'disadvantage'">
                    <span class="text-lg font-bold text-red-500">Desvantagem</span>
                    <span class="text-xs text-red-500/70">2d20 (Menor)</span>
                </Button>
            </div>

            <DialogFooter>
                <Button variant="ghost" @click="$emit('update:open', false)">Cancelar</Button>
                <Button @click="handleConfirm" class="bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90">
                    Rolar
                </Button>
            </DialogFooter>
        </DialogContent>
    </Dialog>
</template>
