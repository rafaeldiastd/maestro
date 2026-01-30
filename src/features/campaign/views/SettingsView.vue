<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { ArrowLeft, Info, Users } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import CampaignInfoTab from '../components/settings/CampaignInfoTab.vue'
import PlayerManagementTab from '../components/settings/PlayerManagementTab.vue'
import { useCampaignSettings } from '@/composables/useCampaignSettings'

const route = useRoute()
const router = useRouter()

const { getCampaignDetails } = useCampaignSettings()

const campaign = ref(null)
const loading = ref(true)
const activeTab = ref('info')
const currentUser = ref(null)

const tabs = [
  { id: 'info', label: 'Informações', icon: Info },
  { id: 'players', label: 'Jogadores', icon: Users }
]

onMounted(async () => {
  // Get current user
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    router.push('/')
    return
  }
  currentUser.value = user

  // Fetch campaign details
  const campaignId = route.params.id
  const result = await getCampaignDetails(campaignId)

  if (result.success) {
    campaign.value = result.data

    // Verify user is the owner
    if (campaign.value.owner_id !== user.id) {
      alert('Você não tem permissão para acessar estas configurações')
      router.push('/dashboard')
      return
    }
  } else {
    alert('Erro ao carregar campanha: ' + result.error)
    router.push('/dashboard')
    return
  }

  loading.value = false
})

const handleCampaignUpdated = (updatedCampaign) => {
  campaign.value = { ...campaign.value, ...updatedCampaign }
}

const goBack = () => {
  router.push(`/play/${route.params.id}`)
}
</script>

<template>
  <div class="min-h-screen w-full bg-lumina-bg text-lumina-text">
    <!-- Header -->
    <header
      class="h-14 border-b border-lumina-border bg-lumina-card px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-4">
        <Button variant="ghost" size="icon" @click="goBack" class="text-lumina-text-muted hover:text-lumina-text">
          <ArrowLeft class="h-5 w-5" />
        </Button>
        <div>
          <h1 class="text-lg font-bold font-serif text-lumina-text">Configurações da Campanha</h1>
          <p v-if="campaign" class="text-xs text-lumina-text-muted">{{ campaign.name }}</p>
        </div>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center h-[calc(100vh-3.5rem)]">
      <div class="text-center">
        <div
          class="inline-block h-8 w-8 border-2 border-lumina-detail border-t-transparent rounded-full animate-spin mb-4">
        </div>
        <p class="text-sm text-lumina-text-muted">Carregando configurações da campanha...</p>
      </div>
    </div>

    <!-- Main Content -->
    <main v-else class="container mx-auto p-8 max-w-4xl">
      <!-- Tabs Navigation -->
      <div class="flex gap-2 mb-6 border-b border-lumina-border">
        <button v-for="tab in tabs" :key="tab.id" @click="activeTab = tab.id" :class="[
          'flex items-center gap-2 px-4 py-3 text-sm font-medium transition-colors relative',
          activeTab === tab.id
            ? 'text-lumina-text'
            : 'text-lumina-text-muted hover:text-lumina-text'
        ]">
          <component :is="tab.icon" class="h-4 w-4" />
          {{ tab.label }}
          <div v-if="activeTab === tab.id" class="absolute bottom-0 left-0 right-0 h-0.5 bg-lumina-detail" />
        </button>
      </div>

      <!-- Tab Content -->
      <div class="bg-lumina-card border border-lumina-border rounded-lg p-6">
        <!-- Campaign Info Tab -->
        <CampaignInfoTab v-if="activeTab === 'info' && campaign" :campaign="campaign"
          @updated="handleCampaignUpdated" />

        <!-- Players Tab -->
        <PlayerManagementTab v-if="activeTab === 'players' && campaign" :campaign-id="campaign.id"
          :is-open="campaign.is_open" :campaign-owner-id="campaign.owner_id" />
      </div>
    </main>
  </div>
</template>
