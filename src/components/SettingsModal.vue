<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
    <div class="bg-lumina-card w-full max-w-md rounded-xl border border-slate-700 p-6 shadow-2xl">
      <div class="mb-4 flex items-center justify-between">
        <h2 class="text-xl font-semibold text-white">Settings</h2>
        <button @click="$emit('close')" class="text-slate-400 hover:text-white">
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>

      <div class="space-y-4">
        <div>
          <label class="mb-1 block text-sm font-medium text-slate-300">Supabase URL</label>
          <input v-model="form.url" type="text" placeholder="https://xyz.supabase.co"
            class="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-white placeholder-slate-500 focus:border-stone-400 focus:ring-1 focus:ring-stone-400 outline-none">
        </div>
        <div>
          <label class="mb-1 block text-sm font-medium text-slate-300">Supabase Anon Key</label>
          <input v-model="form.key" type="password" placeholder="public-anon-key"
            class="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-white placeholder-slate-500 focus:border-stone-400 focus:ring-1 focus:ring-stone-400 outline-none">
        </div>
        <div>
          <label class="mb-1 block text-sm font-medium text-slate-300">Bucket Name</label>
          <input v-model="form.bucket" type="text" placeholder="images"
            class="w-full rounded-lg border border-slate-600 bg-slate-800 px-3 py-2 text-white placeholder-slate-500 focus:border-stone-400 focus:ring-1 focus:ring-stone-400 outline-none">
        </div>
      </div>

      <div class="mt-6 flex justify-end">
        <button @click="save"
          class="rounded-lg bg-stone-100 px-4 py-2 text-sm font-medium text-stone-900 hover:bg-white focus:outline-none focus:ring-2 focus:ring-stone-400 focus:ring-offset-2 focus:ring-offset-slate-900">
          Save & Connect
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps(['isOpen'])
const emit = defineEmits(['close', 'saved'])

const form = ref({
  url: '',
  key: '',
  bucket: 'images'
})

onMounted(() => {
  const stored = JSON.parse(localStorage.getItem('lumina_supabase_config') || '{}')
  if (stored.url) form.value.url = stored.url
  if (stored.key) form.value.key = stored.key
  if (stored.bucket) form.value.bucket = stored.bucket
})

const save = () => {
  if (!form.value.url || !form.value.key || !form.value.bucket) {
    alert('Please fill all fields')
    return
  }

  const config = { ...form.value }
  localStorage.setItem('lumina_supabase_config', JSON.stringify(config))
  emit('saved', config)
  emit('close')
}
</script>
