<script setup>
import { Users, Circle } from 'lucide-vue-next'

const props = defineProps({
  players: {
    type: Array,
    default: () => []
  }
})
</script>

<template>
  <div class="space-y-4">

    <!-- Header -->
    <div class="flex items-center justify-between pb-3 border-b border-lumina-border">
      <div class="flex items-center gap-2">
        <Users class="h-4 w-4 text-lumina-text-muted" />
        <span class="text-xs uppercase tracking-wider font-medium text-lumina-text-muted">Jogadores Conectados</span>
      </div>
      <span class="text-xs font-mono text-lumina-text bg-lumina-bg px-2 py-0.5 rounded border border-lumina-border">
        {{players.filter(p => p.status === 'online').length}} / {{ players.length }}
      </span>
    </div>

    <!-- Players List -->
    <div v-if="players.length > 0" class="space-y-2">
      <div v-for="player in players" :key="player.id"
        class="flex items-center justify-between p-3 rounded-lg bg-lumina-bg border border-lumina-border hover:border-lumina-text-muted/50 transition-colors group">

        <div class="flex items-center gap-3">
          <div class="relative">
            <!-- Avatar / Initials -->
            <div
              class="h-10 w-10 rounded-full bg-lumina-detail/10 border border-lumina-detail/20 flex items-center justify-center text-sm font-bold text-lumina-detail overflow-hidden">
              <img v-if="player.avatar" :src="player.avatar" class="h-full w-full object-cover">
              <span v-else>{{ player.name.charAt(0).toUpperCase() }}</span>
            </div>

            <!-- Status Indicator -->
            <div class="absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full border-2 border-lumina-bg"
              :class="player.status === 'online' ? 'bg-green-500' : 'bg-gray-500'"></div>
          </div>

          <div>
            <p class="text-sm font-medium text-lumina-text group-hover:text-lumina-detail transition-colors">
              {{ player.name }}
            </p>
            <div class="flex items-center gap-2">
              <span class="text-[10px] text-lumina-text-muted uppercase tracking-wider">{{ player.status }}</span>
              <span v-if="player.role === 'master'"
                class="text-[10px] px-1.5 py-0.5 bg-lumina-detail/10 text-lumina-detail rounded border border-lumina-detail/20">DM</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12">
      <div
        class="inline-flex h-12 w-12 items-center justify-center rounded-full bg-lumina-bg border border-lumina-border text-lumina-text-muted mb-3">
        <Users class="h-6 w-6" />
      </div>
      <p class="text-sm text-lumina-text-muted">Nenhum jogador conectado ainda</p>
    </div>
  </div>
</template>
