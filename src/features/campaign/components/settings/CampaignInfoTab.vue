<script setup>
import { ref, computed } from 'vue'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import Textarea from '@/components/ui/textarea/Textarea.vue'
import { Upload, Image as ImageIcon, Calendar } from 'lucide-vue-next'
import { useCampaignSettings } from '@/composables/useCampaignSettings'

const props = defineProps({
  campaign: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['updated'])

const { loading, updateCampaignInfo, uploadCoverPhoto } = useCampaignSettings()

// Form state
const formData = ref({
  name: props.campaign.name || '',
  description: props.campaign.description || '',
  start_date: props.campaign.start_date || '',
  is_open: props.campaign.is_open ?? true
})

const coverPhotoPreview = ref(props.campaign.cover_photo || null)
const selectedFile = ref(null)
const uploadingPhoto = ref(false)

// Handle file selection
const onFileSelect = (event) => {
  const file = event.target.files[0]
  if (file) {
    selectedFile.value = file
    // Create preview
    const reader = new FileReader()
    reader.onload = (e) => {
      coverPhotoPreview.value = e.target.result
    }
    reader.readAsDataURL(file)
  }
}

// Handle form submission
const handleSave = async () => {
  try {
    // Upload cover photo if changed
    if (selectedFile.value) {
      uploadingPhoto.value = true
      const uploadResult = await uploadCoverPhoto(selectedFile.value, props.campaign.id)
      uploadingPhoto.value = false

      if (!uploadResult.success) {
        alert('Erro ao enviar foto de capa: ' + uploadResult.error)
        return
      }

      formData.value.cover_photo = uploadResult.url
    }

    // Update campaign info
    const result = await updateCampaignInfo(props.campaign.id, {
      name: formData.value.name,
      description: formData.value.description,
      start_date: formData.value.start_date || null,
      is_open: formData.value.is_open,
      ...(formData.value.cover_photo && { cover_photo: formData.value.cover_photo })
    })

    if (result.success) {
      emit('updated', result.data)
      alert('Campanha atualizada com sucesso!')
    } else {
      alert('Erro ao atualizar campanha: ' + result.error)
    }
  } catch (error) {
    console.error('Error saving campaign:', error)
    alert('Ocorreu um erro ao salvar')
  }
}

const isSaving = computed(() => loading.value || uploadingPhoto.value)
</script>

<template>
  <div class="space-y-6">
    <!-- Campaign Name -->
    <div class="space-y-2">
      <Label for="campaign-name" class="text-xs uppercase tracking-wider text-lumina-text-muted">
        Nome da Campanha *
      </Label>
      <Input id="campaign-name" v-model="formData.name" required placeholder="Ex: A Maldição de Strahd"
        class="bg-lumina-bg border-lumina-border text-lumina-text placeholder:text-lumina-text-muted/50 focus-visible:ring-lumina-detail" />
    </div>

    <!-- Description -->
    <div class="space-y-2">
      <Label for="campaign-description" class="text-xs uppercase tracking-wider text-lumina-text-muted">
        Descrição
      </Label>
      <Textarea id="campaign-description" v-model="formData.description"
        placeholder="Uma breve descrição da sua campanha..." rows="4"
        class="bg-lumina-bg border-lumina-border text-lumina-text placeholder:text-lumina-text-muted/50 focus-visible:ring-lumina-detail resize-none" />
    </div>

    <!-- Cover Photo -->
    <div class="space-y-2">
      <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">
        Foto de Capa
      </Label>

      <div class="flex gap-4">
        <!-- Preview -->
        <div v-if="coverPhotoPreview"
          class="relative w-32 h-32 rounded-lg border-2 border-lumina-border overflow-hidden bg-lumina-bg group">
          <img :src="coverPhotoPreview" alt="Cover preview" class="w-full h-full object-cover" />
          <div
            class="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
            <ImageIcon class="h-6 w-6 text-white" />
          </div>
        </div>

        <!-- Upload Button -->
        <label
          class="flex-1 flex flex-col items-center justify-center h-32 rounded-lg border-2 border-dashed border-lumina-border hover:border-lumina-text-muted cursor-pointer transition-colors bg-lumina-bg/50">
          <Upload class="h-8 w-8 text-lumina-text-muted mb-2" />
          <span class="text-xs text-lumina-text-muted">Clique para enviar</span>
          <span class="text-[10px] text-lumina-text-muted/70 mt-1">PNG, JPG até 5MB</span>
          <input type="file" accept="image/*" class="hidden" @change="onFileSelect" />
        </label>
      </div>
    </div>

    <!-- Start Date -->
    <div class="space-y-2">
      <Label for="start-date" class="text-xs uppercase tracking-wider text-lumina-text-muted">
        Data de Início
      </Label>
      <div class="relative">
        <Input id="start-date" v-model="formData.start_date" type="date"
          class="bg-lumina-bg border-lumina-border text-lumina-text focus-visible:ring-lumina-detail" />
        <Calendar
          class="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-lumina-text-muted pointer-events-none" />
      </div>
    </div>

    <!-- Campaign Status Toggle -->
    <div class="space-y-2">
      <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">
        Status da Campanha
      </Label>
      <div class="flex items-center gap-3 p-4 rounded-lg border border-lumina-border bg-lumina-bg/50">
        <button type="button" @click="formData.is_open = !formData.is_open" :class="[
          'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
          formData.is_open ? 'bg-green-600' : 'bg-lumina-text-muted'
        ]">
          <span :class="[
            'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
            formData.is_open ? 'translate-x-6' : 'translate-x-1'
          ]" />
        </button>
        <div class="flex-1">
          <div class="flex items-center gap-2">
            <span class="text-sm font-medium text-lumina-text">
              {{ formData.is_open ? 'Aberta' : 'Fechada' }}
            </span>
            <span :class="[
              'h-2 w-2 rounded-full',
              formData.is_open ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.6)]' : 'bg-lumina-text-muted'
            ]" />
          </div>
          <p class="text-xs text-lumina-text-muted mt-0.5">
            {{ formData.is_open ? 'Aceitando novos jogadores' : 'Não aceitando novos jogadores' }}
          </p>
        </div>
      </div>
    </div>

    <!-- Save Button -->
    <div class="flex justify-end pt-4 border-t border-lumina-border">
      <Button @click="handleSave" :disabled="isSaving || !formData.name"
        class="bg-lumina-text text-lumina-bg hover:bg-white font-medium">
        {{ isSaving ? 'Salvando...' : 'Salvar Alterações' }}
      </Button>
    </div>
  </div>
</template>
