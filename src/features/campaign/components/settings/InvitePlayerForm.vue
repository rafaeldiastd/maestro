<script setup>
import { ref } from 'vue'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { UserPlus, Mail, User } from 'lucide-vue-next'
import { useCampaignInvites } from '@/composables/useCampaignInvites'

const props = defineProps({
  campaignId: {
    type: String,
    required: true
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['invited'])

const { loading, sendInvite } = useCampaignInvites()

const usernameOrEmail = ref('')
const errorMessage = ref('')

// Validate email or username
const isValidInput = (value) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  const usernameRegex = /^[a-zA-Z0-9_-]{3,20}$/
  return emailRegex.test(value) || usernameRegex.test(value)
}

const handleInvite = async () => {
  errorMessage.value = ''

  if (!usernameOrEmail.value.trim()) {
    errorMessage.value = 'Por favor, insira um nome de usuário ou e-mail'
    return
  }

  if (!isValidInput(usernameOrEmail.value)) {
    errorMessage.value = 'Formato de nome de usuário ou e-mail inválido'
    return
  }

  console.log('Sending invite for campaign:', props.campaignId, 'to:', usernameOrEmail.value.trim())
  const result = await sendInvite(props.campaignId, usernameOrEmail.value.trim())
  console.log('Send invite result:', result)

  if (result.success) {
    console.log('Emitting invited event with data:', result.data)
    emit('invited', result.data)
    usernameOrEmail.value = ''
    alert('Convite enviado com sucesso!')
  } else {
    errorMessage.value = result.error
    console.error('Error sending invite:', result.error)
  }
}
</script>

<template>
  <div class="space-y-4 p-4 rounded-lg border border-lumina-border bg-lumina-bg/30">
    <div class="flex items-center gap-2 pb-2 border-b border-lumina-border">
      <UserPlus class="h-4 w-4 text-lumina-detail" />
      <h3 class="text-sm font-semibold text-lumina-text">Convidar Jogador</h3>
    </div>

    <div class="space-y-3">
      <div class="space-y-2">
        <Label for="invite-input" class="text-xs uppercase tracking-wider text-lumina-text-muted">
          Nome de Usuário ou E-mail
        </Label>
        <div class="relative">
          <Input id="invite-input" v-model="usernameOrEmail" :disabled="disabled || loading"
            placeholder="jogador@exemplo.com ou usuário"
            class="bg-lumina-bg border-lumina-border text-lumina-text placeholder:text-lumina-text-muted/50 focus-visible:ring-lumina-detail pl-9"
            @keyup.enter="handleInvite" />
          <div class="absolute left-3 top-1/2 -translate-y-1/2">
            <Mail v-if="usernameOrEmail.includes('@')" class="h-4 w-4 text-lumina-text-muted" />
            <User v-else class="h-4 w-4 text-lumina-text-muted" />
          </div>
        </div>
        <p v-if="errorMessage" class="text-xs text-red-400">{{ errorMessage }}</p>
        <p v-else class="text-[10px] text-lumina-text-muted">
          Insira um nome de usuário válido (3-20 caracteres) ou um endereço de e-mail
        </p>
      </div>

      <Button @click="handleInvite" :disabled="disabled || loading || !usernameOrEmail"
        class="w-full bg-lumina-detail/10 hover:bg-lumina-detail/20 text-lumina-detail border border-lumina-detail/20 font-medium">
        <UserPlus class="h-4 w-4 mr-2" />
        {{ loading ? 'Enviando...' : 'Enviar Convite' }}
      </Button>

      <p v-if="disabled" class="text-xs text-center text-lumina-text-muted italic">
        A campanha deve estar aberta para convidar jogadores
      </p>
    </div>
  </div>
</template>
