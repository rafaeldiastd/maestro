<template>
  <div class="min-h-screen w-full bg-lumina-bg text-lumina-text flex flex-col">

    <!-- Navbar -->
    <nav
      class="h-14 border-b border-lumina-border bg-lumina-bg px-6 flex items-center justify-between sticky top-0 z-50">
      <div class="flex items-center gap-2">
        <div
          class="h-6 w-6 rounded bg-lumina-text text-lumina-bg flex items-center justify-center font-bold font-serif text-sm">
          L</div>
        <span class="font-bold font-serif text-lg tracking-tight text-lumina-text">Lumina</span>
      </div>
      <div class="flex items-center gap-4">
        <span class="text-xs font-medium text-lumina-text-muted hidden sm:block">{{ userEmail }}</span>
        <button @click="signOut"
          class="text-xs font-medium text-lumina-text-muted hover:text-lumina-text transition-colors uppercase tracking-wider">Sair</button>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-1 container mx-auto p-8 max-w-6xl">

      <div class="flex items-center justify-between mb-8 pb-4 border-b border-lumina-border">
        <h1 class="text-xl font-bold text-lumina-text tracking-tight">Campanhas</h1>

        <Dialog v-model:open="showNewSessionModal">
          <DialogTrigger as-child>
            <Button
              class="bg-lumina-text/5 hover:bg-lumina-text/10 text-lumina-text border border-lumina-text/10 backdrop-blur-md rounded-full px-4 h-8 text-xs font-medium transition-all hover:scale-105 active:scale-95">
              <span class="mr-2 text-lg leading-none font-light">+</span>
              Nova Sessão
            </Button>
          </DialogTrigger>
          <DialogContent class="sm:max-w-md bg-lumina-card border-lumina-border text-lumina-text p-6 shadow-2xl">
            <DialogHeader>
              <DialogTitle class="text-lg font-serif">Criar Nova Sessão</DialogTitle>
              <DialogDescription class="text-lumina-text-muted text-xs">
                Configure o ambiente da sua nova campanha.
              </DialogDescription>
            </DialogHeader>

            <form @submit.prevent="createSession" class="space-y-4 py-4">
              <div class="space-y-1.5">
                <Label for="name" class="text-xs uppercase tracking-wider text-lumina-text-muted">Nome da
                  Campanha</Label>
                <Input id="name" v-model="newSessionName" required placeholder="Ex: A Maldição de Strahd"
                  class="bg-lumina-bg border-lumina-border text-lumina-text placeholder:text-lumina-text-muted/50 focus-visible:ring-lumina-detail h-9 text-sm" />
              </div>

              <!-- System Selection -->
              <div class="space-y-1.5">
                <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Sistema de Jogo</Label>
                <Select v-model="systemType">
                  <SelectTrigger class="bg-lumina-bg border-lumina-border text-lumina-text h-9 text-sm">
                    <SelectValue placeholder="Selecione um sistema" />
                  </SelectTrigger>
                  <SelectContent class="bg-lumina-card border-lumina-border text-lumina-text">
                    <SelectGroup>
                      <SelectLabel class="text-xs font-serif text-lumina-text-muted">Sistemas</SelectLabel>
                      <SelectItem value="generic">Genérico / Outro</SelectItem>
                      <SelectItem value="dnd5e">D&D 5th Edition</SelectItem>
                      <SelectItem value="pf2e">Pathfinder 2e</SelectItem>
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>

              <!-- Storage Provider Selection -->
              <div class="space-y-2">
                <Label class="text-xs uppercase tracking-wider text-lumina-text-muted">Provedor de Armazenamento</Label>
                <div class="flex gap-2">
                  <label
                    class="flex-1 flex items-center gap-2 cursor-pointer p-2 rounded border border-lumina-border hover:bg-lumina-bg transition-colors"
                    :class="providerType === 'supabase' ? 'bg-lumina-bg ring-1 ring-lumina-detail border-transparent' : ''">
                    <input type="radio" v-model="providerType" value="supabase" class="sr-only">
                      <span class="text-xs font-medium text-lumina-text">Supabase</span>
                  </label>
                  <label
                    class="flex-1 flex items-center gap-2 cursor-pointer p-2 rounded border border-lumina-border hover:bg-lumina-bg transition-colors"
                    :class="providerType === 'cloudinary' ? 'bg-lumina-bg ring-1 ring-lumina-detail border-transparent' : ''">
                    <input type="radio" v-model="providerType" value="cloudinary" class="sr-only">
                      <span class="text-xs font-medium text-lumina-text">Cloudinary</span>
                  </label>
                </div>
              </div>

              <!-- Cloudinary Config -->
              <div v-if="providerType === 'cloudinary'"
                class="space-y-3 p-3 rounded border border-lumina-border bg-lumina-bg/30">
                <div class="grid grid-cols-2 gap-3">
                  <div class="space-y-1">
                    <Label class="text-[10px] uppercase text-lumina-text-muted">Cloud Name</Label>
                    <Input v-model="cloudinaryConfig.cloudName" required
                      class="h-7 text-xs bg-lumina-bg border-lumina-border" />
                  </div>
                  <div class="space-y-1">
                    <Label class="text-[10px] uppercase text-lumina-text-muted">Upload Preset</Label>
                    <Input v-model="cloudinaryConfig.uploadPreset" required
                      class="h-7 text-xs bg-lumina-bg border-lumina-border" />
                  </div>
                  <div class="space-y-1">
                    <Label class="text-[10px] uppercase text-lumina-text-muted">API Key</Label>
                    <Input v-model="cloudinaryConfig.apiKey" class="h-7 text-xs bg-lumina-bg border-lumina-border" />
                  </div>
                  <div class="space-y-1">
                    <Label class="text-[10px] uppercase text-lumina-text-muted">API Secret</Label>
                    <Input v-model="cloudinaryConfig.apiSecret" type="password"
                      class="h-7 text-xs bg-lumina-bg border-lumina-border" />
                  </div>
                </div>
              </div>

              <DialogFooter>
                <Button type="button" variant="ghost" @click="showNewSessionModal = false"
                  class="text-lumina-text-muted hover:text-lumina-text">Cancelar</Button>
                <Button type="submit" :disabled="creating" class="bg-lumina-text text-lumina-bg hover:bg-white">
                  {{ creating ? 'Criando...' : 'Criar' }}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-for="i in 3" :key="i" class="h-32 rounded-md bg-lumina-card border border-lumina-border animate-pulse">
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="sessions.length === 0"
        class="text-center py-20 rounded-lg border border-lumina-border border-dashed opacity-50">
        <div
          class="inline-flex h-12 w-12 items-center justify-center rounded-full bg-lumina-card mb-4 border border-lumina-border text-lumina-text-muted">
          <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
        </div>
        <h3 class="text-sm font-medium text-lumina-text">Nenhuma campanha ainda</h3>
      </div>

      <!-- Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div v-for="session in sessions" :key="session.id" @click="enterSession(session.id)"
          class="group relative rounded-lg border border-lumina-border bg-lumina-card overflow-hidden cursor-pointer h-52 hover:shadow-2xl hover:border-lumina-detail/50 transition-all">

          <!-- Background Image -->
          <div class="absolute inset-0 z-0">
            <img v-if="session.cover_photo" :src="session.cover_photo"
              class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 opacity-80 group-hover:opacity-100"
              alt="Cover" />
            <div v-else
              class="w-full h-full bg-gradient-to-br from-lumina-card to-lumina-bg flex items-center justify-center">
              <span class="text-6xl font-serif text-lumina-text-muted opacity-10">{{ session.name.charAt(0) }}</span>
            </div>
            <!-- Gradient Overlay -->
            <div class="absolute inset-0 bg-gradient-to-t from-black via-black/50 to-transparent opacity-90"></div>
          </div>

          <!-- Content -->
          <div class="relative z-10 p-5 flex flex-col h-full text-white">
            <div class="flex items-start justify-between gap-2">
              <h3
                class="text-xl font-bold font-serif leading-tight drop-shadow-md group-hover:text-lumina-detail transition-colors line-clamp-2">
                {{ session.name }}
              </h3>

              <!-- Badge -->
              <span v-if="session.is_joined"
                class="shrink-0 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider bg-blue-500/20 text-blue-300 border border-blue-500/30 rounded backdrop-blur-sm">
                Jogador
              </span>
              <span v-else
                class="shrink-0 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider bg-lumina-detail/20 text-lumina-detail border border-lumina-detail/30 rounded backdrop-blur-sm">
                Mestre
              </span>
            </div>

            <div class="mt-1 flex items-center gap-2 text-xs text-gray-400 font-medium">
              <span>{{ session.system === 'dnd5e' ? 'D&D 5e' : (session.system === 'pf2e' ? 'Pathfinder 2e' :
                'Sistema Neutro') }}</span>
              <span>•</span>
              <span>{{ new Date(session.created_at).toLocaleDateString() }}</span>
            </div>

            <div
              class="mt-auto flex items-center justify-between pt-4 border-t border-white/10 group-hover:border-lumina-detail/30 transition-colors">
              <div class="flex items-center gap-2">
                <div
                  :class="['w-2 h-2 rounded-full', session.status === 'active' ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.8)]' : 'bg-gray-500']">
                </div>
                <span class="text-[10px] uppercase tracking-wider text-gray-300">{{ session.status }}</span>
              </div>

              <span
                class="text-xs font-bold uppercase tracking-widest opacity-0 transform translate-x-2 group-hover:opacity-100 group-hover:translate-x-0 transition-all duration-300 flex items-center gap-1 text-lumina-detail">
                Entrar <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M5 12h14"></path>
                  <path d="M12 5l7 7-7 7"></path>
                </svg>
              </span>
            </div>
          </div>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'

// Components
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'


const router = useRouter()
const sessions = ref([])
const loading = ref(true)
const userEmail = ref('')
const showNewSessionModal = ref(false)
const newSessionName = ref('')
const creating = ref(false)
const providerType = ref('supabase')
const systemType = ref('generic')
const cloudinaryConfig = ref({
  cloudName: '',
  uploadPreset: '',
  apiKey: '',
  apiSecret: ''
})

const userId = ref('')

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    router.push('/')
    return
  }
  userEmail.value = user.email
  userId.value = user.id
  fetchSessions()
})

const fetchSessions = async () => {
  loading.value = true
  // Fetch Owned Sessions
  const { data: ownedSessions, error: ownedError } = await supabase
    .from('sessions')
    .select('*')
    .eq('owner_id', userId.value)
    .order('created_at', { ascending: false })

  if (ownedError) {
    console.error('Error fetching owned sessions:', ownedError)
  }

  // Fetch Joined Sessions (Member)
  const { data: joinedMemberships, error: joinedError } = await supabase
    .from('campaign_members')
    .select(`
            campaign_id,
            sessions:campaign_id (*)
        `)
    .eq('user_id', userId.value)

  if (joinedError) {
    console.error('Error fetching memberships:', joinedError)
  }

  // Process Joined Sessions
  const joinedSessionsList = (joinedMemberships || [])
    .map(m => m.sessions)
    .filter(s => s) // Filter out nulls
    .map(s => ({ ...s, is_joined: true })) // Mark as joined

  // Combine and Sort
  const allSessions = [...(ownedSessions || []), ...joinedSessionsList]
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))

  sessions.value = allSessions
  loading.value = false
}

const createSession = async () => {
  if (!newSessionName.value) return
  creating.value = true

  const config = providerType.value === 'cloudinary' ? { ...cloudinaryConfig.value } : {}

  const { data, error } = await supabase
    .from('sessions')
    .insert({
      name: newSessionName.value,
      owner_id: userId.value,
      status: 'active',
      storage_provider: providerType.value,
      storage_config: config,
      system: systemType.value
    })
    .select()
    .single() // Return the created row

  creating.value = false

  if (error) {
    alert('Erro ao criar sessão: ' + error.message)
  } else {
    showNewSessionModal.value = false
    newSessionName.value = ''
    // Reset config
    providerType.value = 'supabase'
    systemType.value = 'generic'
    cloudinaryConfig.value = { cloudName: '', uploadPreset: '', apiKey: '', apiSecret: '' }

    sessions.value.unshift(data)
  }
}

const enterSession = (id) => {
  router.push(`/play/${id}`)
}

const signOut = async () => {
  await supabase.auth.signOut()
  router.push('/')
}

</script>
