<template>
  <div
    class="flex min-h-screen w-full items-center justify-center bg-lumina-bg text-lumina-text relative overflow-hidden">

    <!-- Background Decor -->
    <div class="absolute top-[-20%] left-[-10%] h-[500px] w-[500px] rounded-full bg-stone-500/10 blur-[100px]"></div>
    <div class="absolute bottom-[-20%] right-[-10%] h-[500px] w-[500px] rounded-full bg-stone-500/10 blur-[100px]">
    </div>

    <Card class="w-full max-w-md border-lumina-border bg-lumina-card/80 backdrop-blur-2xl shadow-2xl relative z-10">
      <CardHeader class="space-y-1 text-center">
        <CardTitle class="text-3xl font-bold font-serif tracking-tight text-lumina-detail">
          Lumina
        </CardTitle>
        <CardDescription class="text-lumina-text-muted">
          Transmissão Imersiva de Imagens para RPG
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form @submit.prevent="handleAuth" class="space-y-4">

          <div v-if="errorMsg" class="p-3 rounded bg-red-500/10 border border-red-500/20 text-red-200 text-sm">
            {{ errorMsg }}
          </div>

          <!-- Env Warning -->
          <div v-if="!hasEnv" class="p-3 rounded bg-yellow-500/10 border border-yellow-500/20 text-yellow-200 text-sm">
            ⚠️ Supabase Não Configurado. Atualize o arquivo <code>.env</code>.
          </div>

          <div class="space-y-2">
            <Label for="email">Email</Label>
            <Input id="email" v-model="email" type="email" required placeholder="gandalf@middle-earth.com"
              class="bg-lumina-bg border-lumina-border focus-visible:ring-lumina-detail" />
          </div>

          <div class="space-y-2">
            <Label for="password">Senha</Label>
            <Input id="password" v-model="password" type="password" required minlength="6" placeholder="••••••••"
              class="bg-lumina-bg border-lumina-border focus-visible:ring-lumina-detail" />
          </div>

          <Button type="submit"
            class="w-full bg-lumina-detail text-lumina-bg hover:bg-lumina-accent-hover font-bold rounded-lg h-10 shadow-lg shadow-lumina-detail/10 hover:shadow-lumina-detail/20 transition-all hover:-translate-y-0.5"
            :disabled="loading">
            <span v-if="loading" class="flex items-center gap-2">
              <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none">
                </circle>
                <path class="opacity-75" fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                </path>
              </svg>
              Processing...
            </span>
            <span v-else>{{ isSignUp ? 'Criar Conta' : 'Entrar' }}</span>
          </Button>

        </form>
      </CardContent>
      <CardFooter class="flex flex-col gap-2 text-center text-sm text-lumina-text-muted">
        <div v-if="!isSignUp">
          Não tem uma conta?
          <button @click="isSignUp = true; errorMsg = ''"
            class="text-stone-400 hover:text-white font-medium underline-offset-4 hover:underline">Cadastre-se</button>
        </div>
        <div v-else>
          Já tem uma conta?
          <button @click="isSignUp = false; errorMsg = ''"
            class="text-lumina-text hover:text-white font-medium underline-offset-4 hover:underline">Entrar</button>
        </div>
      </CardFooter>
    </Card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { useRouter } from 'vue-router'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from '@/components/ui/card'

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
      errorMsg.value = "Registro bem-sucedido! Verifique seu e-mail para confirmar."
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
