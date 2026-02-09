<template>
    <div class="h-full flex flex-col bg-lumina-card text-lumina-text relative">
        <!-- Header -->
        <div
            class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-lumina-bg/80 backdrop-blur-md">
            <div class="flex items-center gap-2">
                <User class="h-4 w-4 text-lumina-detail" />
                <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Personagens</span>
            </div>
            <Button variant="ghost" size="icon"
                class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
                @click="$emit('close')">
                <X class="h-4 w-4" />
            </Button>
        </div>

        <!-- Content -->
        <div class="flex-1 overflow-y-auto p-4 space-y-4">

            <div v-if="loading" class="text-center py-8 text-lumina-text-muted text-sm">
                Carregando...
            </div>

            <div v-else-if="characters.length === 0" class="text-center py-8 space-y-3">
                <div
                    class="w-12 h-12 rounded-full bg-lumina-bg/50 flex items-center justify-center mx-auto border border-lumina-border border-dashed">
                    <User class="h-6 w-6 text-lumina-text-muted" />
                </div>
                <p class="text-sm text-lumina-text-muted">Você ainda não tem personagens nesta campanha.</p>
                <Button @click="showCreateModal = true" size="sm"
                    class="gap-2 bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90">
                    <Plus class="h-4 w-4" /> Criar Novo
                </Button>
            </div>

            <div v-else class="space-y-3">
                <div v-for="char in characters" :key="char.id"
                    class="group relative bg-lumina-bg border border-lumina-border rounded-lg p-3 hover:border-lumina-detail transition-all cursor-pointer"
                    @click="$emit('select', char)">

                    <div class="flex items-center gap-3">
                        <div
                            class="h-10 w-10 rounded-full bg-lumina-detail/20 flex items-center justify-center border border-lumina-detail/30">
                            <span class="font-serif font-bold text-lumina-detail">{{ char.name.charAt(0).toUpperCase()
                                }}</span>
                        </div>
                        <div>
                            <h3
                                class="font-bold text-sm text-lumina-text leading-tight group-hover:text-lumina-detail transition-colors">
                                {{ char.name }}</h3>
                            <p class="text-xs text-lumina-text-muted">Nível 1 • D&D 5e</p>
                        </div>
                    </div>

                    <div class="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                        <Button variant="ghost" size="icon" class="h-6 w-6 hover:bg-red-500/20 hover:text-red-400"
                            @click.stop="handleDelete(char)">
                            <Trash2 class="h-3 w-3" />
                        </Button>
                    </div>
                </div>

                <Button @click="showCreateModal = true" variant="outline" size="sm"
                    class="w-full gap-2 border-dashed border-lumina-border/50 text-lumina-text-muted hover:text-lumina-text hover:border-lumina-border">
                    <Plus class="h-4 w-4" /> Criar Outro
                </Button>
            </div>

        </div>

        <!-- Create Modal -->
        <CharacterCreationModal v-if="showCreateModal" :open="showCreateModal" :session-id="sessionId" :user-id="userId"
            @close="showCreateModal = false" @created="handleCreated" />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { User, X, Plus, Trash2 } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import CharacterCreationModal from './modals/CharacterCreationModal.vue'

const props = defineProps({
    sessionId: String,
    userId: String
})

const emit = defineEmits(['close', 'select'])

const characters = ref([])
const loading = ref(true)
const showCreateModal = ref(false)

const fetchCharacters = async () => {
    loading.value = true
    const { data, error } = await supabase
        .from('characters')
        .select('*')
        .eq('session_id', props.sessionId)
        .eq('user_id', props.userId)
        .order('created_at', { ascending: false })

    if (data) {
        characters.value = data
    }
    loading.value = false
}

const handleCreated = (newChar) => {
    characters.value.unshift(newChar)
    emit('select', newChar) // Auto-select newly created
}

const handleDelete = async (char) => {
    if (!confirm(`Tem certeza que deseja excluir ${char.name}?`)) return

    const { error } = await supabase.from('characters').delete().eq('id', char.id)
    if (!error) {
        characters.value = characters.value.filter(c => c.id !== char.id)
    }
}

onMounted(() => {
    fetchCharacters()
})

</script>
