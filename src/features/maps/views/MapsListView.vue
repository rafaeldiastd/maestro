<template>
  <div class="h-screen w-screen bg-lumina-bg flex flex-col">
    <!-- Header -->
    <div class="h-14 border-b border-lumina-border bg-lumina-card flex items-center justify-between px-6 shrink-0">
      <div class="flex items-center gap-3">
        <Button @click="$router.push(`/campaign/${campaignId}`)" variant="ghost" size="sm" class="gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="2">
            <path d="M19 12H5M12 19l-7-7 7-7" />
          </svg>
          Back to Campaign
        </Button>

        <div class="h-6 w-px bg-lumina-border"></div>

        <h1 class="text-lg font-bold font-inknut text-lumina-text">Map Editor</h1>
      </div>

      <Button @click="createMap" size="sm" class="gap-2">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="currentColor" stroke-width="2">
          <path d="M12 5v14M5 12h14" />
        </svg>
        New Map
      </Button>
    </div>

    <!-- Maps Grid -->
    <div class="flex-1 overflow-y-auto p-6">
      <div v-if="maps.length === 0" class="flex items-center justify-center h-full">
        <div class="text-center">
          <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" stroke-width="1" class="mx-auto mb-4 text-lumina-text-muted">
            <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
          </svg>
          <p class="text-lg font-inknut text-lumina-text mb-2">No Maps Yet</p>
          <p class="text-sm text-lumina-text-muted mb-4">Create your first map to get started</p>
          <Button @click="createMap" size="sm">Create Map</Button>
        </div>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        <div
          v-for="map in maps"
          :key="map.id"
          class="group relative bg-lumina-card border border-lumina-border rounded-lg overflow-hidden hover:border-lumina-detail transition-all cursor-pointer"
          @click="editMap(map)"
        >
          <!-- Thumbnail -->
          <div class="aspect-video bg-lumina-bg relative overflow-hidden">
            <img
              v-if="map.background_url"
              :src="map.background_url"
              class="w-full h-full object-cover"
              alt="Map preview"
            />
            <div v-else class="w-full h-full flex items-center justify-center">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="1" class="text-lumina-text-muted">
                <path d="M3 3h18v18H3zM9 3v18M15 3v18M3 9h18M3 15h18" />
              </svg>
            </div>

            <!-- Active Badge -->
            <div
              v-if="map.is_active"
              class="absolute top-2 right-2 bg-green-600 text-white text-xs font-bold px-2 py-1 rounded flex items-center gap-1"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <path d="M20 6 9 17l-5-5" />
              </svg>
              Active
            </div>

            <!-- Hover Overlay -->
            <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
              <span class="text-white font-bold">Edit Map</span>
            </div>
          </div>

          <!-- Info -->
          <div class="p-4">
            <h3 class="font-bold text-sm text-lumina-text mb-1 truncate">{{ map.name }}</h3>
            <p class="text-xs text-lumina-text-muted">
              {{ map.width }}×{{ map.height }}px · {{ map.grid_cell_width }}px grid
            </p>
          </div>

          <!-- Actions -->
          <div class="absolute top-2 left-2 opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
            <Button
              @click.stop="toggleActive(map)"
              variant="ghost"
              size="sm"
              class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-lumina-bg"
              :title="map.is_active ? 'Deactivate' : 'Activate'"
            >
              <svg v-if="!map.is_active" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10" />
              </svg>
              <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" stroke-width="2">
                <path d="M20 6 9 17l-5-5" />
              </svg>
            </Button>

            <Button
              @click.stop="deleteMap(map)"
              variant="ghost"
              size="sm"
              class="h-7 w-7 p-0 bg-lumina-card/90 hover:bg-red-500/20 text-red-400"
              title="Delete"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none"
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
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { Button } from '@/components/ui/button'

const route = useRoute()
const router = useRouter()
const campaignId = route.params.id

const maps = ref([])

onMounted(async () => {
  await fetchMaps()
})

const fetchMaps = async () => {
  const { data } = await supabase
    .from('campaign_maps')
    .select('*')
    .eq('session_id', campaignId)
    .order('created_at', { ascending: false })
  
  if (data) maps.value = data
}

const createMap = async () => {
  const { data } = await supabase
    .from('campaign_maps')
    .insert({
      session_id: campaignId,
      name: 'New Map',
      width: 800,
      height: 600,
      grid_cell_width: 50,
      grid_cell_height: 50,
      grid_color: '#ffffff',
      grid_opacity: 0.3,
      grid_offset_top: 0,
      grid_offset_bottom: 0,
      grid_offset_left: 0,
      grid_offset_right: 0,
      grid_line_width: 1
    })
    .select()
    .single()
  
  if (data) {
    maps.value.unshift(data)
    editMap(data)
  }
}

const editMap = (map) => {
  router.push(`/campaign/${campaignId}/map/${map.id}`)
}

const toggleActive = async (map) => {
  // Deactivate all others first
  await supabase
    .from('campaign_maps')
    .update({ is_active: false })
    .eq('session_id', campaignId)
    .neq('id', map.id)
  
  // Toggle this one
  const newState = !map.is_active
  await supabase
    .from('campaign_maps')
    .update({ is_active: newState })
    .eq('id', map.id)
  
  await fetchMaps()
}

const deleteMap = async (map) => {
  if (!confirm(`Delete "${map.name}"? This cannot be undone.`)) return
  
  await supabase
    .from('campaign_maps')
    .delete()
    .eq('id', map.id)
  
  await fetchMaps()
}
</script>
