<script setup>
import { ref, watch, onMounted } from 'vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label' // Assuming exists or will use basic label
import { X, Save, User as UserIcon } from 'lucide-vue-next'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter
} from '@/components/ui/dialog'
import { useCharacter } from '@/composables/useCharacter'

const props = defineProps({
    isOpen: {
        type: Boolean,
        default: false
    },
    campaignId: {
        type: String,
        required: true
    },
    userId: {
        type: String,
        required: true
    },
    existingCharacter: {
        type: Object,
        default: null
    }
})

const emit = defineEmits(['update:isOpen', 'saved'])

// Form State
const form = ref({
    name: '',
    class: '',
    race: '',
    level: 1,
    avatar_url: ''
})

const { upsertCharacter, loading, error } = useCharacter()

// Watch for open to reset/init form
watch(() => props.isOpen, (newVal) => {
    if (newVal) {
        if (props.existingCharacter) {
            form.value = { ...props.existingCharacter }
        } else {
            // Reset defaults
            form.value = {
                name: '',
                class: '',
                race: '',
                level: 1,
                avatar_url: ''
            }
        }
    }
})

const handleSave = async () => {
    if (!form.value.name) return // Simple validation

    try {
        const payload = {
            ...form.value,
            campaign_id: props.campaignId,
            user_id: props.userId,
            id: props.existingCharacter?.id // Include ID for update
        }

        const savedChar = await upsertCharacter(payload)
        if (savedChar) {
            emit('saved', savedChar)
            emit('update:isOpen', false)
        }
    } catch (e) {
        // Error handled in composable state
    }
}

const handleClose = () => {
    emit('update:isOpen', false)
}

</script>

<template>
    <Dialog :open="isOpen" @update:open="handleClose">
        <DialogContent
            class="sm:max-w-[425px] bg-lumina-card border-lumina-border text-lumina-text p-0 overflow-hidden gap-0">

            <!-- Header -->
            <div class="p-6 border-b border-lumina-border bg-lumina-bg/50">
                <DialogHeader>
                    <DialogTitle class="text-xl font-serif font-bold text-lumina-detail">Ficha de Personagem
                    </DialogTitle>
                    <DialogDescription class="text-lumina-text-muted text-xs">
                        Crie seu avatar neste mundo.
                    </DialogDescription>
                </DialogHeader>
            </div>

            <!-- Body -->
            <div class="p-6 space-y-4">

                <!-- Avatar Preview/Input -->
                <div class="flex items-center gap-4">
                    <div
                        class="h-16 w-16 rounded-full border-2 border-lumina-border bg-lumina-bg flex items-center justify-center overflow-hidden shrink-0">
                        <img v-if="form.avatar_url" :src="form.avatar_url" class="h-full w-full object-cover" />
                        <UserIcon v-else class="h-8 w-8 text-lumina-text-muted" />
                    </div>
                    <div class="flex-1 space-y-1">
                        <label class="text-xs font-bold text-lumina-text uppercase tracking-wider">Avatar URL</label>
                        <Input v-model="form.avatar_url" placeholder="https://..."
                            class="h-8 text-xs bg-lumina-bg border-lumina-border" />
                    </div>
                </div>

                <div class="space-y-1">
                    <label class="text-xs font-bold text-lumina-text uppercase tracking-wider">Nome do
                        Personagem</label>
                    <Input v-model="form.name" placeholder="Ex: Thorik, o Bravo"
                        class="bg-lumina-bg border-lumina-border font-serif font-medium" />
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div class="space-y-1">
                        <label class="text-xs font-bold text-lumina-text uppercase tracking-wider">Classe</label>
                        <Input v-model="form.class" placeholder="Ex: Guerreiro"
                            class="bg-lumina-bg border-lumina-border" />
                    </div>
                    <div class="space-y-1">
                        <label class="text-xs font-bold text-lumina-text uppercase tracking-wider">Raça</label>
                        <Input v-model="form.race" placeholder="Ex: Anão" class="bg-lumina-bg border-lumina-border" />
                    </div>
                </div>

                <div class="space-y-1">
                    <label class="text-xs font-bold text-lumina-text uppercase tracking-wider">Nível</label>
                    <Input v-model="form.level" type="number" min="1" max="20"
                        class="bg-lumina-bg border-lumina-border w-24" />
                </div>

                <!-- Error Message -->
                <div v-if="error" class="text-red-400 text-xs bg-red-900/10 p-2 rounded border border-red-900/20">
                    {{ error }}
                </div>

            </div>

            <!-- Footer -->
            <div class="p-4 border-t border-lumina-border bg-lumina-bg/50 flex justify-end gap-2">
                <Button variant="ghost" size="sm" @click="handleClose"
                    class="text-lumina-text-muted hover:text-white">Cancelar</Button>
                <Button size="sm" @click="handleSave" :disabled="loading"
                    class="bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90 gap-2">
                    <Save class="h-4 w-4" />
                    {{ loading ? 'Salvando...' : 'Salvar Ficha' }}
                </Button>
            </div>

        </DialogContent>
    </Dialog>
</template>
