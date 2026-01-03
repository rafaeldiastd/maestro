<template>
    <div
        class="flex min-h-screen w-full items-center justify-center bg-lumina-bg text-lumina-text relative overflow-hidden">

        <!-- Background Decor -->
        <div class="absolute top-[-20%] left-[-10%] h-[500px] w-[500px] rounded-full bg-stone-500/10 blur-[100px]">
        </div>
        <div class="absolute bottom-[-20%] right-[-10%] h-[500px] w-[500px] rounded-full bg-stone-500/10 blur-[100px]">
        </div>

        <div
            class="w-full max-w-md p-8 relative z-10 backdrop-blur-2xl bg-slate-900/60 rounded-2xl border border-slate-800 shadow-2xl">

            <!-- Brand -->
            <div class="mb-8 text-center">

                <h1
                    class="text-4xl font-bold tracking-tight bg-gradient-to-r from-stone-200 to-stone-500 bg-clip-text text-transparent mb-2">
                    Lumina
                </h1>
                <p class="text-slate-400">Immersive RPG Image Broadcasting</p>
            </div>

            <!-- Auth Form -->
            <form @submit.prevent="handleAuth" class="space-y-4">

                <div v-if="errorMsg"
                    class="p-3 rounded bg-red-500/10 border border-red-500/20 text-red-200 text-sm mb-4">
                    {{ errorMsg }}
                </div>

                <!-- Env Warning -->
                <div v-if="!hasEnv"
                    class="p-3 rounded bg-yellow-500/10 border border-yellow-500/20 text-yellow-200 text-sm mb-4">
                    ⚠️ Supabase Not Configured. Update <code>.env</code> file.
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-400 mb-1">Email</label>
                    <input v-model="email" type="email" required
                        class="w-full rounded-lg bg-slate-800 border border-slate-700 px-4 py-2 text-white focus:border-stone-400 focus:outline-none focus:ring-1 focus:ring-stone-400 transition-all placeholder:text-slate-600"
                        placeholder="gandalf@middle-earth.com">
                </div>

                <div>
                    <label class="block text-sm font-medium text-slate-400 mb-1">Password</label>
                    <input v-model="password" type="password" required minlength="6"
                        class="w-full rounded-lg bg-slate-800 border border-slate-700 px-4 py-2 text-white focus:border-stone-400 focus:outline-none focus:ring-1 focus:ring-stone-400 transition-all placeholder:text-slate-600"
                        placeholder="••••••••">
                </div>

                <button type="submit" :disabled="loading"
                    class="w-full rounded-lg bg-stone-100 px-4 py-2.5 font-semibold text-stone-900 shadow-lg hover:bg-white focus:outline-none focus:ring-2 focus:ring-stone-400 focus:ring-offset-2 focus:ring-offset-slate-900 disabled:opacity-50 disabled:cursor-not-allowed transition-all">
                    <span v-if="loading" class="flex items-center justify-center gap-2">
                        <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"
                                fill="none"></circle>
                            <path class="opacity-75" fill="currentColor"
                                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                            </path>
                        </svg>
                        Processing...
                    </span>
                    <span v-else>{{ isSignUp ? 'Create Account' : 'Sign In' }}</span>
                </button>

            </form>

            <div class="mt-6 text-center text-sm text-slate-500">
                <p v-if="!isSignUp">
                    Don't have an account?
                    <button @click="isSignUp = true; errorMsg = ''"
                        class="text-stone-400 hover:text-white font-medium">Sign Up</button>
                </p>
                <p v-else>
                    Already have an account?
                    <button @click="isSignUp = false; errorMsg = ''"
                        class="text-stone-400 hover:text-white font-medium">Sign In</button>
                </p>
            </div>

        </div>
    </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMsg = ref('')
const isSignUp = ref(false)
const hasEnv = !!import.meta.env.VITE_SUPABASE_URL


const handleAuth = async () => {
    loading.value = true
    errorMsg.value = ''

    try {
        if (isSignUp.value) {
            const { error } = await supabase.auth.signUp({
                email: email.value,
                password: password.value
            })
            if (error) throw error

            // Check if email confirmation is required (Supabase default)
            errorMsg.value = "Registration successful! Please check your email to confirm."
            // If auto-confirm is on in dev, we could auto-login, but let's assume secure flow.

        } else {
            const { error } = await supabase.auth.signInWithPassword({
                email: email.value,
                password: password.value
            })
            if (error) throw error

            router.push('/dashboard')
        }
    } catch (e) {
        errorMsg.value = e.message
    } finally {
        loading.value = false
    }
}
</script>
