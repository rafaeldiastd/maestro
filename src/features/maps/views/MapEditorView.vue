<template>
  <div v-if="map" class="h-screen w-screen">
    <MapCanvas 
      :map="map" 
      :all-maps="allMaps"
      :is-gm="true" 
      @close="handleClose" 
      @update:map="handleUpdate"
      @change-map="handleChangeMap"
      @create-map="handleCreateMap"
    />
  </div>
  <div v-else class="h-screen w-screen flex items-center justify-center bg-lumina-bg">
    <p class="text-lumina-text-muted">Loading map...</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import MapCanvas from '../components/MapCanvas.vue'

const route = useRoute()
const router = useRouter()
const campaignId = route.params.id
const mapId = ref(route.params.mapId)

const map = ref(null)
const allMaps = ref([])

onMounted(async () => {
  await fetchAllMaps()
  await fetchMap()
})

const fetchAllMaps = async () => {
  const { data } = await supabase
    .from('campaign_maps')
    .select('*')
    .eq('session_id', campaignId)
    .order('created_at', { ascending: false })
  
  if (data) allMaps.value = data
}

const fetchMap = async () => {
  const { data } = await supabase
    .from('campaign_maps')
    .select('*')
    .eq('id', mapId.value)
    .single()
  
  if (data) {
    map.value = data
  } else {
    // Map not found, redirect back
    router.push(`/campaign/${campaignId}/maps`)
  }
}

const handleClose = () => {
  router.push(`/campaign/${campaignId}/maps`)
}

const handleUpdate = async (updatedMap) => {
  // Optimistic update
  map.value = updatedMap
  
  // Update in allMaps list
  const idx = allMaps.value.findIndex(m => m.id === updatedMap.id)
  if (idx !== -1) allMaps.value[idx] = updatedMap
  
  // If activating, deactivate others
  if (updatedMap.is_active) {
    await supabase
      .from('campaign_maps')
      .update({ is_active: false })
      .eq('session_id', campaignId)
      .neq('id', updatedMap.id)
    
    // Update local state
    allMaps.value.forEach(m => {
      if (m.id !== updatedMap.id) m.is_active = false
    })
  }
  
  // Save to database
  await supabase
    .from('campaign_maps')
    .update({
      name: updatedMap.name,
      width: updatedMap.width,
      height: updatedMap.height,
      grid_cols: updatedMap.grid_cols,
      grid_rows: updatedMap.grid_rows,
      grid_cell_width: updatedMap.grid_cell_width,
      grid_cell_height: updatedMap.grid_cell_height,
      grid_color: updatedMap.grid_color,
      grid_opacity: updatedMap.grid_opacity,
      grid_line_width: updatedMap.grid_line_width,
      grid_offset_top: updatedMap.grid_offset_top,
      grid_offset_bottom: updatedMap.grid_offset_bottom,
      grid_offset_left: updatedMap.grid_offset_left,
      grid_offset_right: updatedMap.grid_offset_right,
      background_url: updatedMap.background_url,
      is_active: updatedMap.is_active
    })
    .eq('id', mapId.value)
}

const handleChangeMap = (newMapId) => {
  router.push(`/campaign/${campaignId}/map/${newMapId}`)
}

const handleCreateMap = async () => {
  const { data } = await supabase
    .from('campaign_maps')
    .insert({
      session_id: campaignId,
      name: 'New Map',
      width: 800,
      height: 600,
      grid_cols: 20,
      grid_rows: 15,
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
    allMaps.value.unshift(data)
    router.push(`/campaign/${campaignId}/map/${data.id}`)
  }
}
</script>
