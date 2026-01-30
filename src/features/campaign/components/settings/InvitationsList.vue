<script setup>
import { ref, computed } from 'vue'
import { X, Mail, User, Clock, Copy, Check } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { useCampaignInvites } from '@/composables/useCampaignInvites'

const props = defineProps({
  invitations: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['revoked'])

const { loading, revokeInvite } = useCampaignInvites()
const copiedId = ref(null)

const copyInviteLink = async (invite) => {
  const baseUrl = window.location.origin
  const inviteLink = `${baseUrl}/invite/accept/${invite.invite_token}`

  try {
    await navigator.clipboard.writeText(inviteLink)
    copiedId.value = invite.id

    // Reset after 2 seconds
    setTimeout(() => {
      copiedId.value = null
    }, 2000)
  } catch (err) {
    console.error('Failed to copy:', err)
    alert('Falha ao copiar link')
  }
}

const handleRevoke = async (inviteId) => {
  if (!confirm('Tem certeza que deseja revogar este convite?')) return

  const result = await revokeInvite(inviteId)

  if (result.success) {
    emit('revoked', inviteId)
    alert('Convite revogado')
  } else {
    alert('Erro ao revogar convite: ' + result.error)
  }
}

const getStatusColor = (status) => {
  switch (status) {
    case 'pending': return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20'
    case 'accepted': return 'bg-green-500/10 text-green-500 border-green-500/20'
    case 'rejected': return 'bg-red-500/10 text-red-500 border-red-500/20'
    case 'revoked': return 'bg-lumina-text-muted/10 text-lumina-text-muted border-lumina-text-muted/20'
    default: return 'bg-lumina-bg text-lumina-text border-lumina-border'
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const pendingInvitations = computed(() => {
  console.log('Computing pending invitations from:', props.invitations)
  const pending = props.invitations.filter(inv => inv.status === 'pending')
  console.log('Pending invitations:', pending)
  return pending
})

</script>

<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between pb-2 border-b border-lumina-border">
      <div class="flex items-center gap-2">
        <Clock class="h-4 w-4 text-lumina-text-muted" />
        <h3 class="text-sm font-semibold text-lumina-text">Convites Pendentes</h3>
      </div>
      <span
        class="text-xs font-mono text-lumina-text-muted bg-lumina-bg px-2 py-0.5 rounded border border-lumina-border">
        {{ pendingInvitations.length }}
      </span>
    </div>

    <!-- Invitations List -->
    <div v-if="pendingInvitations.length > 0" class="space-y-2">
      <div v-for="invite in pendingInvitations" :key="invite.id"
        class="flex items-center justify-between p-3 rounded-lg bg-lumina-bg border border-lumina-border hover:border-lumina-text-muted/50 transition-colors">
        <div class="flex items-center gap-3 flex-1 min-w-0">
          <div
            class="flex-shrink-0 h-8 w-8 rounded-full bg-lumina-detail/10 border border-lumina-detail/20 flex items-center justify-center">
            <Mail v-if="invite.username_or_email.includes('@')" class="h-4 w-4 text-lumina-detail" />
            <User v-else class="h-4 w-4 text-lumina-detail" />
          </div>

          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-lumina-text truncate">
              {{ invite.username_or_email }}
            </p>
            <p class="text-xs text-lumina-text-muted">
              Enviado em {{ formatDate(invite.created_at) }}
            </p>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <span
            :class="['text-[10px] uppercase tracking-wider font-medium px-2 py-1 rounded border', getStatusColor(invite.status)]">
            {{ invite.status }}
          </span>

          <!-- Copy Link Button -->
          <Button v-if="invite.status === 'pending'" variant="ghost" size="icon" @click="copyInviteLink(invite)"
            class="h-7 w-7 text-lumina-text-muted hover:text-lumina-detail hover:bg-lumina-detail/10"
            :title="copiedId === invite.id ? 'Copiado!' : 'Copiar link de convite'">
            <Check v-if="copiedId === invite.id" class="h-4 w-4 text-green-500" />
            <Copy v-else class="h-4 w-4" />
          </Button>

          <!-- Revoke Button -->
          <Button v-if="invite.status === 'pending'" variant="ghost" size="icon" @click="handleRevoke(invite.id)"
            :disabled="loading" class="h-7 w-7 text-lumina-text-muted hover:text-red-400 hover:bg-red-400/10">
            <X class="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-8 rounded-lg border border-dashed border-lumina-border bg-lumina-bg/30">
      <div
        class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-lumina-bg border border-lumina-border text-lumina-text-muted mb-2">
        <Clock class="h-5 w-5" />
      </div>
      <p class="text-sm text-lumina-text-muted">Nenhum convite pendente</p>
      <p class="text-xs text-lumina-text-muted/70 mt-1">Convide jogadores para começar</p>
    </div>
  </div>
</template>
