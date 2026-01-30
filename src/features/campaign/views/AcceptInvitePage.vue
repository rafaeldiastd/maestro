<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { useCampaignInvites } from '@/composables/useCampaignInvites'
import { Button } from '@/components/ui/button'
import { CheckCircle, XCircle, Loader2, Users } from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()

const { getInviteByToken, acceptInvite, loading } = useCampaignInvites()

const invitation = ref(null)
const loadingInvite = ref(true)
const error = ref(null)
const accepting = ref(false)
const accepted = ref(false)
const isLoggedIn = ref(false)

onMounted(async () => {
  // Check if user is logged in
  const { data: { user } } = await supabase.auth.getUser()
  isLoggedIn.value = !!user

  // Load invitation details
  const token = route.params.token
  
  if (!token) {
    error.value = 'Invalid invitation link'
    loadingInvite.value = false
    return
  }

  console.log('Loading invitation with token:', token)
  const result = await getInviteByToken(token)
  console.log('Invitation result:', result)

  if (result.success) {
    invitation.value = result.data
    
    // Check if already accepted/revoked
    if (invitation.value.status !== 'pending') {
      error.value = `This invitation has been ${invitation.value.status}`
    }
  } else {
    if (result.error.includes('0 rows')) {
      error.value = 'Invitation not found. This link may be invalid or expired.'
    } else {
      error.value = result.error || 'Invitation not found'
    }
    console.error('Error loading invitation:', result.error)
  }

  loadingInvite.value = false
})

const handleAccept = async () => {
  if (!isLoggedIn.value) {
    // Redirect to login with return URL
    router.push({
      path: '/',
      query: { redirect: route.fullPath }
    })
    return
  }

  accepting.value = true
  const result = await acceptInvite(route.params.token)

  if (result.success) {
    accepted.value = true
    // Redirect to campaign after 2 seconds
    setTimeout(() => {
      router.push(`/join/${result.campaignId}`)
    }, 2000)
  } else {
    error.value = result.error
  }

  accepting.value = false
}

const goToLogin = () => {
  router.push({
    path: '/',
    query: { redirect: route.fullPath }
  })
}
</script>

<template>
  <div class="min-h-screen w-full bg-lumina-bg text-lumina-text flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <!-- Loading State -->
      <div v-if="loadingInvite" class="text-center py-12">
        <Loader2 class="h-12 w-12 text-lumina-detail animate-spin mx-auto mb-4" />
        <p class="text-sm text-lumina-text-muted">Loading invitation...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-lumina-card border border-red-500/20 rounded-lg p-8 text-center">
        <div class="inline-flex h-16 w-16 items-center justify-center rounded-full bg-red-500/10 border border-red-500/20 mb-4">
          <XCircle class="h-8 w-8 text-red-500" />
        </div>
        <h2 class="text-xl font-bold font-serif text-lumina-text mb-2">Invalid Invitation</h2>
        <p class="text-sm text-lumina-text-muted mb-6">{{ error }}</p>
        <Button
          @click="router.push('/dashboard')"
          variant="outline"
          class="border-lumina-border text-lumina-text hover:bg-lumina-bg"
        >
          Go to Dashboard
        </Button>
      </div>

      <!-- Success State -->
      <div v-else-if="accepted" class="bg-lumina-card border border-green-500/20 rounded-lg p-8 text-center">
        <div class="inline-flex h-16 w-16 items-center justify-center rounded-full bg-green-500/10 border border-green-500/20 mb-4">
          <CheckCircle class="h-8 w-8 text-green-500" />
        </div>
        <h2 class="text-xl font-bold font-serif text-lumina-text mb-2">Invitation Accepted!</h2>
        <p class="text-sm text-lumina-text-muted mb-2">
          You've joined <span class="text-lumina-text font-semibold">{{ invitation.campaign?.name }}</span>
        </p>
        <p class="text-xs text-lumina-text-muted">Redirecting to campaign...</p>
      </div>

      <!-- Invitation Details -->
      <div v-else-if="invitation" class="bg-lumina-card border border-lumina-border rounded-lg overflow-hidden">
        <!-- Cover Photo -->
        <div 
          v-if="invitation.campaign?.cover_photo"
          class="h-48 bg-cover bg-center relative"
          :style="{ backgroundImage: `url(${invitation.campaign.cover_photo})` }"
        >
          <div class="absolute inset-0 bg-gradient-to-b from-transparent to-lumina-card"></div>
        </div>
        <div v-else class="h-48 bg-gradient-to-br from-lumina-bg via-lumina-card to-lumina-bg flex items-center justify-center">
          <Users class="h-16 w-16 text-lumina-text-muted/20" />
        </div>

        <!-- Content -->
        <div class="p-8">
          <div class="text-center mb-6">
            <h1 class="text-2xl font-bold font-serif text-lumina-text mb-2">
              Campaign Invitation
            </h1>
            <p class="text-sm text-lumina-text-muted">
              You've been invited to join
            </p>
          </div>

          <div class="bg-lumina-bg border border-lumina-border rounded-lg p-4 mb-6">
            <h2 class="text-lg font-bold font-serif text-lumina-text mb-2">
              {{ invitation.campaign?.name }}
            </h2>
            <p v-if="invitation.campaign?.description" class="text-sm text-lumina-text-muted">
              {{ invitation.campaign.description }}
            </p>
          </div>

          <!-- Not Logged In Warning -->
          <div v-if="!isLoggedIn" class="bg-yellow-500/5 border border-yellow-500/20 rounded-lg p-4 mb-6">
            <p class="text-sm text-yellow-500 mb-3">
              You need to be logged in to accept this invitation
            </p>
            <Button
              @click="goToLogin"
              class="w-full bg-lumina-text text-lumina-bg hover:bg-white"
            >
              Login to Accept
            </Button>
          </div>

          <!-- Accept Button -->
          <Button
            v-else
            @click="handleAccept"
            :disabled="accepting"
            class="w-full bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90 font-semibold"
          >
            <Loader2 v-if="accepting" class="h-4 w-4 mr-2 animate-spin" />
            {{ accepting ? 'Accepting...' : 'Accept Invitation' }}
          </Button>

          <p class="text-xs text-center text-lumina-text-muted mt-4">
            Invited by {{ invitation.username_or_email }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
