<script setup>
import { Users, Crown, UserMinus } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { useCampaignInvites } from '@/composables/useCampaignInvites'

const props = defineProps({
  members: {
    type: Array,
    default: () => []
  },
  campaignOwnerId: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['removed'])

const { loading, removeMember } = useCampaignInvites()

const handleRemove = async (member) => {
  if (!confirm(`Remover este jogador da campanha?`)) return

  const result = await removeMember(props.campaignId, member.user_id)

  if (result.success) {
    emit('removed', member.user_id)
    alert('Membro removido da campanha')
  } else {
    alert('Erro ao remover membro: ' + result.error)
  }
}

const getInitials = (identifier) => {
  return identifier ? identifier.charAt(0).toUpperCase() : '?'
}

const getRoleBadgeClass = (role) => {
  if (role === 'master') {
    return 'bg-lumina-detail/10 text-lumina-detail border-lumina-detail/20'
  }
  return 'bg-blue-500/10 text-blue-400 border-blue-500/20'
}
</script>

<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between pb-2 border-b border-lumina-border">
      <div class="flex items-center gap-2">
        <Users class="h-4 w-4 text-lumina-text-muted" />
        <h3 class="text-sm font-semibold text-lumina-text">Membros da Campanha</h3>
      </div>
      <span
        class="text-xs font-mono text-lumina-text-muted bg-lumina-bg px-2 py-0.5 rounded border border-lumina-border">
        {{ members.length }}
      </span>
    </div>

    <!-- Members List -->
    <div v-if="members.length > 0" class="space-y-2">
      <div v-for="member in members" :key="member.id"
        class="flex items-center justify-between p-3 rounded-lg bg-lumina-bg border border-lumina-border hover:border-lumina-text-muted/50 transition-colors">
        <div class="flex items-center gap-3">
          <div class="relative">
            <div
              class="h-9 w-9 rounded-full bg-lumina-detail/10 border border-lumina-detail/20 flex items-center justify-center text-sm font-bold text-lumina-detail">
              {{ getInitials(member.email || member.user_id) }}
            </div>
            <Crown v-if="member.role === 'master'" class="absolute -top-1 -right-1 h-4 w-4 text-lumina-detail" />
          </div>

          <div>
            <p class="text-sm font-medium text-lumina-text">
              {{ member.email || 'Usuário Desconhecido' }}
            </p>
            <p class="text-xs text-lumina-text-muted">
              Entrou em {{ new Date(member.joined_at).toLocaleDateString() }}
            </p>
          </div>
        </div>

        <div class="flex items-center gap-2">
          <span
            :class="['text-[10px] uppercase tracking-wider font-medium px-2 py-1 rounded border', getRoleBadgeClass(member.role)]">
            {{ member.role }}
          </span>

          <!-- Only show remove button for players, not master -->
          <Button v-if="member.role !== 'master'" variant="ghost" size="icon" @click="handleRemove(member)"
            :disabled="loading" class="h-7 w-7 text-lumina-text-muted hover:text-red-400 hover:bg-red-400/10">
            <UserMinus class="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-8 rounded-lg border border-dashed border-lumina-border bg-lumina-bg/30">
      <div
        class="inline-flex h-10 w-10 items-center justify-center rounded-full bg-lumina-bg border border-lumina-border text-lumina-text-muted mb-2">
        <Users class="h-5 w-5" />
      </div>
      <p class="text-sm text-lumina-text-muted">Nenhum membro ainda</p>
      <p class="text-xs text-lumina-text-muted/70 mt-1">Convide jogadores para entrar na sua campanha</p>
    </div>
  </div>
</template>
