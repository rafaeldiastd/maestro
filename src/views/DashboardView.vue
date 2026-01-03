<template>
    <div class="min-h-screen w-full bg-lumina-bg text-lumina-text flex flex-col">

        <!-- Navbar -->
        <nav
            class="h-16 border-b border-slate-800 bg-slate-900/50 backdrop-blur px-6 flex items-center justify-between sticky top-0 z-50">
            <div class="flex items-center gap-2">
                <div
                    class="h-8 w-8 rounded bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center font-bold text-white">
                    L</div>
                <span class="font-bold text-xl tracking-tight">Lumina</span>
            </div>
            <div class="flex items-center gap-4">
                <span class="text-sm text-slate-400 hidden sm:block">{{ userEmail }}</span>
                <button @click="signOut"
                    class="text-sm font-medium text-slate-400 hover:text-white transition-colors">Sign Out</button>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="flex-1 container mx-auto p-6 max-w-5xl">

            <div class="flex items-center justify-between mb-8">
                <h1 class="text-3xl font-bold">Your Campaigns</h1>
                <button @click="showNewSessionModal = true"
                    class="rounded-lg bg-indigo-600 px-4 py-2 text-white font-semibold hover:bg-indigo-500 transition-all shadow-lg shadow-indigo-500/20 flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="12" y1="5" x2="12" y2="19"></line>
                        <line x1="5" y1="12" x2="19" y2="12"></line>
                    </svg>
                    New Session
                </button>
            </div>

            <!-- Loading -->
            <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div v-for="i in 3" :key="i" class="h-48 rounded-xl bg-slate-800 animate-pulse"></div>
            </div>

            <!-- Empty State -->
            <div v-else-if="sessions.length === 0"
                class="text-center py-20 rounded-2xl bg-slate-900/50 border border-slate-800 border-dashed">
                <div class="inline-flex h-16 w-16 items-center justify-center rounded-full bg-slate-800 mb-4">
                    <svg class="h-8 w-8 text-slate-500" xmlns="http://www.w3.org/2000/svg" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                </div>
                <h3 class="text-xl font-medium text-white">No campaigns yet</h3>
                <p class="text-slate-500 mt-2 max-w-sm mx-auto">Create your first campaign session to start sharing
                    images with your players.</p>
            </div>

            <!-- Grid -->
            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div v-for="session in sessions" :key="session.id" @click="enterSession(session.id)"
                    class="group relative h-48 rounded-xl bg-slate-800 border border-slate-700 p-6 flex flex-col justify-between hover:border-indigo-500 hover:shadow-xl hover:shadow-indigo-500/10 cursor-pointer transition-all">
                    <div>
                        <div class="flex items-start justify-between">
                            <h3 class="text-xl font-bold text-white group-hover:text-indigo-400 transition-colors">{{
                                session.name }}</h3>
                            <span
                                :class="session.status === 'active' ? 'bg-green-500/10 text-green-400 border-green-500/20' : 'bg-slate-700 text-slate-400'"
                                class="px-2 py-0.5 rounded text-xs font-mono border">
                                {{ session.status }}
                            </span>
                        </div>
                        <p class="text-slate-500 text-sm mt-2">Created {{ new
                            Date(session.created_at).toLocaleDateString() }}</p>
                    </div>

                    <div class="flex items-center justify-between mt-4">
                        <div class="flex -space-x-2 overflow-hidden">
                            <!-- Avatars placeholder (future feature) -->
                            <div
                                class="inline-block h-8 w-8 rounded-full ring-2 ring-slate-800 bg-slate-600 flex items-center justify-center text-xs text-white">
                                DM</div>
                        </div>
                        <span
                            class="text-sm font-medium text-indigo-400 group-hover:translate-x-1 transition-transform flex items-center gap-1">
                            Launch
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <path d="M5 12h14"></path>
                                <path d="M12 5l7 7-7 7"></path>
                            </svg>
                        </span>
                    </div>
                </div>
            </div>

        </main>

        <!-- New Session Modal -->
        <div v-if="showNewSessionModal"
            class="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
            <div class="w-full max-w-md rounded-xl bg-slate-900 border border-slate-700 p-6 shadow-2xl">
                <h2 class="text-xl font-bold mb-4">Create New Session</h2>
                <form @submit.prevent="createSession">
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-slate-400 mb-1">Campaign Name</label>
                        <input v-model="newSessionName" type="text" required placeholder="Ex: Curse of Strahd"
                            class="w-full rounded bg-slate-800 border border-slate-600 px-3 py-2 text-white focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
                    </div>
                    <div class="flex items-center justify-end gap-3">
                        <button type="button" @click="showNewSessionModal = false"
                            class="px-4 py-2 text-sm font-medium text-slate-300 hover:text-white">Cancel</button>
                        <button type="submit" :disabled="creating"
                            class="rounded bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-500 disabled:opacity-50">
                            {{ creating ? 'Creating...' : 'Create' }}
                        </button>
                    </div>
                </form>
            </div>
        </div>

    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabaseClient'

const router = useRouter()
const sessions = ref([])
const loading = ref(true)
const userEmail = ref('')
const showNewSessionModal = ref(false)
const newSessionName = ref('')
const creating = ref(false)

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
    const { data, error } = await supabase
        .from('sessions')
        .select('*')
        .eq('owner_id', userId.value)
        .order('created_at', { ascending: false })

    if (error) {
        console.error('Error fetching sessions:', error)
    } else {
        sessions.value = data
    }
    loading.value = false
}

const createSession = async () => {
    if (!newSessionName.value) return
    creating.value = true

    const { data, error } = await supabase
        .from('sessions')
        .insert({
            name: newSessionName.value,
            owner_id: userId.value,
            status: 'active'
        })
        .select()
        .single() // Return the created row

    creating.value = false

    if (error) {
        alert('Error creating session: ' + error.message)
    } else {
        showNewSessionModal.value = false
        newSessionName.value = ''
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
