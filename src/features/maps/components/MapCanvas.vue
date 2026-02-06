<template>
  <div class="h-full w-full bg-background flex flex-col">
    <!-- Navbar with Maps List -->
    <div class="h-14 border-b border-border bg-card flex items-center justify-between px-4 shrink-0">
      <div class="flex items-center gap-3 flex-1 min-w-0">
        <Button @click="$emit('close')" variant="default" size="sm" class="gap-2 shrink-0">
          <ArrowLeft class="h-4 w-4" />
          Back
        </Button>

        <div class="h-6 w-px bg-border shrink-0"></div>

        <!-- Maps Dropdown -->
        <select :value="map.id" @change="$emit('change-map', $event.target.value)"
          class="bg-background border border-border rounded px-3 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none min-w-0 max-w-xs">
          <option v-for="m in allMaps" :key="m.id" :value="m.id">
            {{ m.name }} {{ m.is_active ? '(Active)' : '' }}
          </option>
        </select>

        <Button @click="$emit('create-map')" variant="default" size="sm" class="gap-2 shrink-0">
          <Plus class="h-3.5 w-3.5" />
          New Map
        </Button>
      </div>

      <div class="flex items-center gap-3 shrink-0">
        <!-- Grid Toggle -->
        <Button @click="gridVisible = !gridVisible" :variant="gridVisible ? 'default' : 'secondary'" size="sm"
          class="gap-2">
          <Grid3X3 class="h-3.5 w-3.5" />
          Grid
        </Button>

        <div class="h-6 w-px bg-border"></div>

        <!-- Zoom -->
        <div class="flex items-center gap-1 px-2 py-1 bg-background rounded">
          <Button @click="handleZoom(-1)" variant="ghost" size="sm" class="h-7 w-7 p-0">
            <ZoomOut class="h-3.5 w-3.5" />
          </Button>
          <span class="text-xs font-mono w-12 text-center text-foreground">{{ Math.round(camera.zoom * 100) }}%</span>
          <Button @click="handleZoom(1)" variant="ghost" size="sm" class="h-7 w-7 p-0">
            <ZoomIn class="h-3.5 w-3.5" />
          </Button>
        </div>

        <div class="h-6 w-px bg-border"></div>

        <!-- Activate Map -->
        <Button @click="toggleMapActive" :variant="map.is_active ? 'default' : 'outline'" size="sm" class="gap-2"
          :class="map.is_active ? 'bg-green-600 hover:bg-green-700 text-white' : ''">
          <Check v-if="map.is_active" class="h-3.5 w-3.5" />
          {{ map.is_active ? 'Active' : 'Activate' }}
        </Button>

        <!-- Settings Toggle -->
        <Button @click="settingsOpen = !settingsOpen" :variant="settingsOpen ? 'default' : 'outline'" size="sm"
          class="gap-2">
          <Settings class="h-3.5 w-3.5" />
          Settings
        </Button>
      </div>
    </div>

    <!-- Main Content Area -->
    <div class="flex-1 flex overflow-hidden">
      <!-- Canvas -->
      <div class="flex-1 relative overflow-hidden bg-background" @mousedown="handleMouseDown"
        @mousemove="handleMouseMove" @mouseup="handleMouseUp" @wheel="handleWheel">
        <canvas ref="canvasRef" class="w-full h-full cursor-default"></canvas>
      </div>

      <!-- Grid Settings Sidebar -->
      <div v-if="settingsOpen" class="w-80 border-l border-border bg-card flex flex-col overflow-hidden">
        <div class="h-14 shrink-0 border-b border-border flex items-center justify-between px-4">
          <h3 class="font-bold text-sm font-serif text-foreground">Grid Settings</h3>
          <Button @click="settingsOpen = false" variant="ghost" size="sm" class="h-7 w-7 p-0">
            <X class="h-4 w-4" />
          </Button>
        </div>

        <div class="flex-1 overflow-y-auto p-4 space-y-6">
          <!-- Grid Dimensions -->
          <div class="space-y-3">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Grid Dimensions</h4>

            <div class="grid grid-cols-2 gap-3">
              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Columns</label>
                <input v-model.number="gridCols" @change="updateGridSettings" type="number" min="1"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Rows</label>
                <input v-model.number="gridRows" @change="updateGridSettings" type="number" min="1"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>
            </div>
          </div>

          <!-- Cell Size -->
          <div class="space-y-3">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Cell Size</h4>

            <div class="grid grid-cols-2 gap-3">
              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Width (px)</label>
                <input v-model.number="gridCellWidth" @change="updateGridSettings" type="number" min="10"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Height (px)</label>
                <input v-model.number="gridCellHeight" @change="updateGridSettings" type="number" min="10"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>
            </div>
          </div>

          <!-- Offsets (Gaps) -->
          <div class="space-y-3">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Offsets (Gap)</h4>

            <div class="grid grid-cols-2 gap-3">
              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Left (px)</label>
                <input v-model.number="gridOffsetLeft" @change="updateGridSettings" type="number" min="0"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Right (px)</label>
                <input v-model.number="gridOffsetRight" @change="updateGridSettings" type="number" min="0"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Top (px)</label>
                <input v-model.number="gridOffsetTop" @change="updateGridSettings" type="number" min="0"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Bottom (px)</label>
                <input v-model.number="gridOffsetBottom" @change="updateGridSettings" type="number" min="0"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>
            </div>
          </div>

          <!-- Line Settings -->
          <div class="space-y-3">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Line Settings</h4>

            <div class="space-y-3">
              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Color</label>
                <div class="flex gap-2">
                  <input v-model="gridColor" @change="updateGridSettings" type="color"
                    class="h-9 w-16 rounded border border-border cursor-pointer" />
                  <input v-model="gridColor" @change="updateGridSettings" type="text"
                    class="flex-1 bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none font-mono" />
                </div>
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Width (px)</label>
                <input v-model.number="gridLineWidth" @change="updateGridSettings" type="number" min="1" max="10"
                  step="0.5"
                  class="w-full bg-background border border-border rounded px-2 py-1.5 text-sm text-foreground focus:border-primary focus:outline-none" />
              </div>

              <div class="space-y-1">
                <label class="text-xs text-muted-foreground">Opacity</label>
                <div class="flex items-center gap-3">
                  <input v-model.number="gridOpacity" @input="updateGridSettings" type="range" min="0" max="1"
                    step="0.05" class="flex-1" />
                  <span class="text-xs font-mono w-12 text-foreground">{{ Math.round(gridOpacity * 100) }}%</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Map Info -->
          <div class="space-y-3 pt-3 border-t border-border">
            <h4 class="text-xs font-bold text-muted-foreground uppercase tracking-wider">Map Info</h4>
            <div class="text-xs text-muted-foreground space-y-1">
              <p>Image: {{ mapWidth }}×{{ mapHeight }}px</p>
              <p>Grid Area: {{ gridAreaWidth }}×{{ gridAreaHeight }}px</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed } from 'vue'
import { useMapEditor } from '@/composables/useMapEditor'
import { Button } from '@/components/ui/button'
import {
  ArrowLeft,
  Plus,
  Grid3X3,
  ZoomIn,
  ZoomOut,
  Check,
  Settings,
  X
} from 'lucide-vue-next'

const props = defineProps({
  map: { type: Object, required: true },
  allMaps: { type: Array, default: () => [] },
  isGm: { type: Boolean, default: true }
})

const emit = defineEmits(['close', 'update:map', 'change-map', 'create-map'])

// Map editor composable
const {
  camera,
  gridColor,
  gridOpacity,
  initCanvas,
  loadBackground,
  panCamera,
  zoomCamera,
  cleanup,
  backgroundImage,
  mapWidth,
  mapHeight
} = useMapEditor()

const canvasRef = ref(null)
const gridVisible = ref(true)
const settingsOpen = ref(true)

// Grid settings from map
const gridCols = ref(props.map.grid_cols || 20)
const gridRows = ref(props.map.grid_rows || 15)
const gridCellWidth = ref(props.map.grid_cell_width || 50)
const gridCellHeight = ref(props.map.grid_cell_height || 50)
const gridOffsetLeft = ref(props.map.grid_offset_left || 0)
const gridOffsetRight = ref(props.map.grid_offset_right || 0)
const gridOffsetTop = ref(props.map.grid_offset_top || 0)
const gridOffsetBottom = ref(props.map.grid_offset_bottom || 0)
const gridLineWidth = ref(props.map.grid_line_width || 1)

// Computed grid area
const gridAreaWidth = computed(() => {
  return mapWidth.value - gridOffsetLeft.value - gridOffsetRight.value
})

const gridAreaHeight = computed(() => {
  return mapHeight.value - gridOffsetTop.value - gridOffsetBottom.value
})

// Mouse state for pan
const mouseDown = ref(false)
const lastMousePos = ref({ x: 0, y: 0 })
const spacePressed = ref(false)

let animationFrameId = null

onMounted(async () => {
  await nextTick()
  if (!canvasRef.value) return

  initCanvas(canvasRef.value, props.map.settings)

  // Set grid settings from map
  gridColor.value = props.map.grid_color || '#ffffff'
  gridOpacity.value = props.map.grid_opacity !== undefined ? props.map.grid_opacity : 0.3

  if (props.map.background_url) {
    try {
      await loadBackground(props.map.background_url)
    } catch (e) {
      console.error('Failed to load background:', e)
    }
  }

  // Keyboard listeners
  window.addEventListener('keydown', handleKeyDown)
  window.addEventListener('keyup', handleKeyUp)

  startRenderLoop()
})

const startRenderLoop = () => {
  const frame = () => {
    renderCanvas()
    animationFrameId = requestAnimationFrame(frame)
  }
  animationFrameId = requestAnimationFrame(frame)
}

const renderCanvas = () => {
  if (!canvasRef.value) return

  const ctx = canvasRef.value.getContext('2d')
  const w = canvasRef.value.width
  const h = canvasRef.value.height

  // Clear
  ctx.clearRect(0, 0, w, h)

  // Save context
  ctx.save()

  // Apply camera transform
  ctx.translate(camera.value.x, camera.value.y)
  ctx.scale(camera.value.zoom, camera.value.zoom)

  // Draw background
  if (backgroundImage.value) {
    ctx.drawImage(backgroundImage.value, 0, 0, mapWidth.value, mapHeight.value)
  } else {
    ctx.fillStyle = '#1a1a1a'
    ctx.fillRect(0, 0, mapWidth.value, mapHeight.value)
  }

  // Draw grid
  if (gridVisible.value) {
    drawGrid(ctx)
  }

  ctx.restore()
}

const drawGrid = (ctx) => {
  const startX = gridOffsetLeft.value
  const startY = gridOffsetTop.value
  const endX = mapWidth.value - gridOffsetRight.value
  const endY = mapHeight.value - gridOffsetBottom.value

  ctx.strokeStyle = gridColor.value
  ctx.globalAlpha = gridOpacity.value
  ctx.lineWidth = gridLineWidth.value / camera.value.zoom

  // Draw grid boundary
  ctx.strokeRect(startX, startY, endX - startX, endY - startY)

  // Vertical lines
  for (let i = 1; i < gridCols.value; i++) {
    const x = startX + (i * gridCellWidth.value)
    if (x < endX) {
      ctx.beginPath()
      ctx.moveTo(x, startY)
      ctx.lineTo(x, endY)
      ctx.stroke()
    }
  }

  // Horizontal lines
  for (let i = 1; i < gridRows.value; i++) {
    const y = startY + (i * gridCellHeight.value)
    if (y < endY) {
      ctx.beginPath()
      ctx.moveTo(startX, y)
      ctx.lineTo(endX, y)
      ctx.stroke()
    }
  }

  ctx.globalAlpha = 1.0
}

const updateGridSettings = () => {
  emit('update:map', {
    ...props.map,
    grid_cols: gridCols.value,
    grid_rows: gridRows.value,
    grid_cell_width: gridCellWidth.value,
    grid_cell_height: gridCellHeight.value,
    grid_offset_left: gridOffsetLeft.value,
    grid_offset_right: gridOffsetRight.value,
    grid_offset_top: gridOffsetTop.value,
    grid_offset_bottom: gridOffsetBottom.value,
    grid_color: gridColor.value,
    grid_opacity: gridOpacity.value,
    grid_line_width: gridLineWidth.value
  })
}

const toggleMapActive = () => {
  emit('update:map', { ...props.map, is_active: !props.map.is_active })
}

// Pan controls
const handleKeyDown = (e) => {
  if (e.code === 'Space' && !e.repeat) {
    spacePressed.value = true
    e.preventDefault()
  }
}

const handleKeyUp = (e) => {
  if (e.code === 'Space') {
    spacePressed.value = false
    e.preventDefault()
  }
}

const handleMouseDown = (e) => {
  if (spacePressed.value) {
    mouseDown.value = true
    lastMousePos.value = { x: e.clientX, y: e.clientY }
  }
}

const handleMouseMove = (e) => {
  if (!mouseDown.value || !spacePressed.value) return

  const deltaX = e.clientX - lastMousePos.value.x
  const deltaY = e.clientY - lastMousePos.value.y

  panCamera(deltaX, deltaY)
  lastMousePos.value = { x: e.clientX, y: e.clientY }
}

const handleMouseUp = () => {
  mouseDown.value = false
}

const handleWheel = (e) => {
  if (!canvasRef.value) return
  const rect = canvasRef.value.getBoundingClientRect()
  const centerX = e.clientX - rect.left
  const centerY = e.clientY - rect.top
  zoomCamera(e.deltaY, centerX, centerY)
}

const handleZoom = (direction) => {
  if (!canvasRef.value) return
  const centerX = canvasRef.value.width / 2
  const centerY = canvasRef.value.height / 2
  zoomCamera(direction > 0 ? -100 : 100, centerX, centerY)
}

onUnmounted(() => {
  if (animationFrameId) cancelAnimationFrame(animationFrameId)
  window.removeEventListener('keydown', handleKeyDown)
  window.removeEventListener('keyup', handleKeyUp)
  cleanup()
})
</script>
