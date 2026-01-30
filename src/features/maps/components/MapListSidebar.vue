<template>
  <div class="fixed left-16 top-0 bottom-0 z-30 w-80 bg-lumina-card/95 backdrop-blur-xl border-r border-lumina-border shadow-2xl">
    <div class="h-full flex flex-col">
      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-lumina-bg/80 backdrop-blur-md">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2" class="text-lumina-detail">
            <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
          </svg>
          <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Maps</span>
        </div>
        <Button 
          variant="ghost" 
          size="icon" 
          class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg"
          @click="$emit('close')"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M18 6 6 18M6 6l12 12" />
          </svg>
        </Button>
      </div>
      
      <!-- Create Button -->
      <div class="p-4 border-b border-lumina-border shrink-0">
        <Button @click="$emit('create-map')" size="sm" class="w-full gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M12 5v14M5 12h14" />
          </svg>
          Create New Map
        </Button>
      </div>
      
      <!-- Map List -->
      <div class="flex-1 overflow-y-auto p-4 space-y-2">
        <div
          v-for="map in maps"
          :key="map.id"
          class="group relative bg-lumina-bg border border-lumina-border rounded-lg overflow-hidden hover:border-lumina-detail transition-all cursor-pointer"
          @click="$emit('select-map', map)"
        >
          <div class="aspect-video bg-lumina-bg/50 relative">
            <img
              v-if="map.background_url"
              :src="map.background_url"
              class="w-full h-full object-cover"
              alt="Map preview"
            />
            <div v-else class="w-full h-full flex items-center justify-center">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="1" class="text-lumina-text-muted">
                <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
              </svg>
            </div>
            
            <div
              v-if="map.is_active"
              class="absolute top-2 right-2 bg-green-600 text-white text-xs font-bold px-2 py-1 rounded flex items-center gap-1"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <path d="M20 6 9 17l-5-5" />
              </svg>
              Active
            </div>
          </div>
          
          <div class="p-3">
            <h3 class="font-bold text-sm text-lumina-text truncate">{{ map.name }}</h3>
            <p class="text-xs text-lumina-text-muted mt-1">{{ map.width }}×{{ map.height }}px</p>
          </div>
          
          <div class="absolute top-2 left-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
            <Button
              @click.stop="$emit('activate-map', map)"
              variant="ghost"
              size="sm"
              class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-lumina-bg"
              :title="map.is_active ? 'Deactivate' : 'Activate'"
            >
              <svg v-if="!map.is_active" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10" />
              </svg>
              <svg v-else xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <path d="M20 6 9 17l-5-5" />
              </svg>
            </Button>
            
            <Button
              @click.stop="$emit('delete-map', map)"
              variant="ghost"
              size="sm"
              class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-red-500/20 text-red-400"
              title="Delete"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <path d="M3 6h18M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
              </svg>
            </Button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Button } from '@/components/ui/button'

defineProps({
  maps: { type: Array, default: () => [] }
})

defineEmits(['close', 'create-map', 'select-map', 'activate-map', 'delete-map'])
</script>
