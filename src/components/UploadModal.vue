<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
    <div class="bg-lumina-card w-full max-w-md rounded-xl border border-slate-700 p-6 shadow-2xl">
      <h2 class="mb-4 text-xl font-semibold text-white">Uploading...</h2>

      <div class="mb-2 h-2.5 w-full rounded-full bg-slate-700">
        <div class="h-2.5 rounded-full bg-stone-100 transition-all duration-300" :style="{ width: progress + '%' }">
        </div>
      </div>

      <p class="text-sm text-slate-400">{{ status }}</p>
    </div>
  </div>
</template>

<script setup>
defineProps(['isOpen', 'progress', 'status'])
</script>
