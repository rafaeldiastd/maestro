<template>
    <div v-if="open" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
        <div
            class="w-full max-w-md bg-lumina-card border border-lumina-border rounded-lg shadow-xl overflow-hidden p-6 space-y-6">

            <div class="flex items-center justify-between">
                <h2 class="text-xl font-serif font-bold text-lumina-text">Criar Novo Personagem</h2>
                <Button variant="ghost" size="icon" @click="$emit('close')">
                    <X class="h-4 w-4" />
                </Button>
            </div>

            <div class="space-y-4">
                <div class="space-y-2">
                    <Label>Nome do Personagem</Label>
                    <Input v-model="form.name" placeholder="Ex: Gandalf, o Cinzento"
                        class="bg-lumina-bg border-lumina-border" />
                </div>

                <div class="space-y-2">
                    <Label>Sistema / Modelo</Label>
                    <div v-if="loadingTemplates" class="text-sm text-lumina-text-muted">Carregando modelos...</div>
                    <div v-else class="grid grid-cols-1 gap-2">
                        <div v-for="tpl in templates" :key="tpl.id"
                            class="flex items-center justify-between p-3 rounded border cursor-pointer hover:border-lumina-detail transition-colors"
                            :class="form.templateId === tpl.id ? 'border-lumina-detail bg-lumina-detail/10' : 'border-lumina-border bg-lumina-bg/20'"
                            @click="form.templateId = tpl.id">
                            <span class="font-medium text-sm">{{ tpl.name }}</span>
                            <Check v-if="form.templateId === tpl.id" class="h-4 w-4 text-lumina-detail" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex card-footer justify-end gap-2 pt-2">
                <Button variant="ghost" @click="$emit('close')">Cancelar</Button>
                <Button :disabled="!isValid || isSubmitting" @click="handleSubmit"
                    class="bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90">
                    {{ isSubmitting ? 'Criando...' : 'Criar Personagem' }}
                </Button>
            </div>

        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, reactive } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { X, Check } from 'lucide-vue-next'

const props = defineProps({
    open: Boolean,
    sessionId: String,
    userId: String
})

const emit = defineEmits(['close', 'created'])

const form = reactive({
    name: '',
    templateId: null
})

const templates = ref([])
const loadingTemplates = ref(true)
const isSubmitting = ref(false)

const isValid = computed(() => form.name.trim().length > 0 && form.templateId)

onMounted(async () => {
    try {
        const { data, error } = await supabase.from('sheet_templates').select('id, name, system_key, schema')
        if (error) throw error
        templates.value = data
        // Auto-select if only one
        if (data.length > 0) form.templateId = data[0].id
    } catch (e) {
        console.error('Failed to load templates', e)
    } finally {
        loadingTemplates.value = false
    }
})

const handleSubmit = async () => {
    if (!isValid.value) return
    isSubmitting.value = true

    try {
        const selectedTemplate = templates.value.find(t => t.id === form.templateId)
        // Initialize data structure based on schema logic (simplified for now: empty object, schema handles defaults later or we init here)
        // Ideally we should process the schema to build the initial JSON. 
        // For now we trust the migration default or empty.
        // Let's build a basic default from the schema if possible, or just empty.

        // Simple backend initialization via default is '{}', but let's try to be smarter if we can. 
        // Since we are in frontend, let's just send empty and let the sheet component handle defaults, 
        // OR we can parse the schema. The schema has "default" keys. 
        // Let's do a quick pass to populate defaults.
        const initialData = {}

        if (selectedTemplate?.schema?.attributes) {
            initialData.attributes = {}
            selectedTemplate.schema.attributes.forEach(attr => {
                initialData.attributes[attr.key] = attr.default ?? 10
            })
        }
        if (selectedTemplate?.schema?.stats) {
            selectedTemplate.schema.stats.forEach(stat => {
                initialData[stat.key] = stat.default
            })
        }

        const { data, error } = await supabase.from('characters').insert({
            session_id: props.sessionId,
            user_id: props.userId,
            name: form.name,
            data: initialData
        }).select().single()

        if (error) throw error

        emit('created', data)
        emit('close')
        // Reset form
        form.name = ''

    } catch (e) {
        console.error('Error creating character:', e)
    } finally {
        isSubmitting.value = false
    }
}

</script>
