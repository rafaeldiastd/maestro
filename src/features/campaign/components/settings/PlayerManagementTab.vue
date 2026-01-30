<script setup>
import { ref, onMounted, computed } from 'vue'
import { AlertCircle } from 'lucide-vue-next'
import InvitePlayerForm from './InvitePlayerForm.vue'
import InvitationsList from './InvitationsList.vue'
import MembersList from './MembersList.vue'
import { useCampaignInvites } from '@/composables/useCampaignInvites'

const props = defineProps({
  campaignId: {
    type: String,
    required: true
  },
  isOpen: {
    type: Boolean,
    default: true
  },
  campaignOwnerId: {
    type: String,
    required: true
  }
})

const { getInvitations, getMembers } = useCampaignInvites()

const invitations = ref([])
const members = ref([])
const loading = ref(false)

const loadData = async () => {
  loading.value = true

  console.log('Loading invitations for campaign:', props.campaignId)

  const [invitesResult, membersResult] = await Promise.all([
    getInvitations(props.campaignId),
    getMembers(props.campaignId)
  ])

  console.log('Invitations result:', invitesResult)
  console.log('Members result:', membersResult)

  if (invitesResult.success) {
    invitations.value = invitesResult.data
    console.log('Loaded invitations:', invitations.value)
  } else {
    console.error('Error loading invitations:', invitesResult.error)
  }

  if (membersResult.success) {
    members.value = membersResult.data
    console.log('Loaded members:', members.value)
  } else {
    console.error('Error loading members:', membersResult.error)
  }

  loading.value = false
}

const handleInvited = (newInvite) => {
  console.log('New invite received:', newInvite)
  invitations.value.unshift(newInvite)
  console.log('Updated invitations list:', invitations.value)
}

const handleRevoked = (inviteId) => {
  const index = invitations.value.findIndex(inv => inv.id === inviteId)
  if (index !== -1) {
    invitations.value[index].status = 'revoked'
  }
}

const handleRemoved = (userId) => {
  members.value = members.value.filter(m => m.user_id !== userId)
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="space-y-6">
    <!-- Closed Campaign Warning -->
    <div v-if="!isOpen" class="flex items-start gap-3 p-4 rounded-lg border border-yellow-500/20 bg-yellow-500/5">
      <AlertCircle class="h-5 w-5 text-yellow-500 flex-shrink-0 mt-0.5" />
      <div>
        <h4 class="text-sm font-semibold text-yellow-500 mb-1">A Campanha está Fechada</h4>
        <p class="text-xs text-lumina-text-muted">
          Esta campanha não está aceitando novos jogadores. Abra a campanha na aba Informações para habilitar convites.
        </p>
      </div>
    </div>

    <!-- Invite Form -->
    <InvitePlayerForm :campaign-id="campaignId" :disabled="!isOpen" @invited="handleInvited" />

    <!-- Invitations List -->
    <InvitationsList :invitations="invitations" @revoked="handleRevoked" />

    <!-- Members List -->
    <MembersList :members="members" :campaign-id="campaignId" :campaign-owner-id="campaignOwnerId"
      @removed="handleRemoved" />

    <!-- Loading State -->
    <div v-if="loading" class="text-center py-4">
      <div class="inline-block h-6 w-6 border-2 border-lumina-detail border-t-transparent rounded-full animate-spin">
      </div>
      <p class="text-xs text-lumina-text-muted mt-2">Carregando...</p>
    </div>
  </div>
</template>
