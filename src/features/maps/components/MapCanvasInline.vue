<template>
  <div class="absolute inset-0 bg-lumina-bg">
    <canvas 
      ref="canvasRef" 
      class="w-full h-full cursor-grab"
      :class="{ 'cursor-grabbing': mouseDown && spacePressed }"
      @mousedown="handleMouseDown"
      @mousemove="handleMouseMove"
      @mouseup="handleMouseUp"
      @mouseleave="handleMouseUp"
      @wheel.prevent="handleWheel"
    ></canvas>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useMapEditor } from '@/composables/useMapEditor'

const props = defineProps({
  map: { type: Object, required: true },
  showGrid: { type: Boolean, default: true },
  currentLayer: { type: String, default: 'map' } // 'map' | 'gm' | 'tokens'
})

const emit = defineEmits(['update:map'])

// Map editor composable
const {
  camera,
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

// Mouse state for pan
const mouseDown = ref(false)
const lastMousePos = ref({ x: 0, y: 0 })
const spacePressed = ref(false)

let animationFrameId = null

onMounted(async () => {
  await nextTick()
  if (!canvasRef.value) return
  
  initCanvas(canvasRef.value)

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

// Watch for map changes
watch(() => props.map.background_url, async (newUrl) => {
  if (newUrl) {
    try {
      await loadBackground(newUrl)
    } catch (e) {
      console.error('Failed to load background:', e)
    }
  }
})

// Watch for grid settings changes (reactive updates)
watch(
  () => ({
    cols: props.map.grid_cols,
    rows: props.map.grid_rows,
    cellWidth: props.map.grid_cell_width,
    cellHeight: props.map.grid_cell_height,
    offsetLeft: props.map.grid_offset_left,
    offsetRight: props.map.grid_offset_right,
    offsetTop: props.map.grid_offset_top,
    offsetBottom: props.map.grid_offset_bottom,
    color: props.map.grid_color,
    opacity: props.map.grid_opacity,
    lineWidth: props.map.grid_line_width
  }),
  () => {
    // Grid will be redrawn automatically in render loop
  },
  { deep: true }
)

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
  if (props.showGrid) {
    drawGrid(ctx)
  }

  // TODO: Draw tokens based on currentLayer

  ctx.restore()
}

const drawGrid = (ctx) => {
  const startX = props.map.grid_offset_left || 0
  const startY = props.map.grid_offset_top || 0
  const endX = mapWidth.value - (props.map.grid_offset_right || 0)
  const endY = mapHeight.value - (props.map.grid_offset_bottom || 0)
  
  const cols = props.map.grid_cols || 20
  const rows = props.map.grid_rows || 15
  const cellWidth = props.map.grid_cell_width || 50
  const cellHeight = props.map.grid_cell_height || 50
  
  ctx.strokeStyle = props.map.grid_color || '#ffffff'
  ctx.globalAlpha = props.map.grid_opacity !== undefined ? props.map.grid_opacity : 0.3
  ctx.lineWidth = (props.map.grid_line_width || 1) / camera.value.zoom

  // Draw grid boundary
  ctx.strokeRect(startX, startY, endX - startX, endY - startY)

  // Vertical lines
  for (let i = 1; i < cols; i++) {
    const x = startX + (i * cellWidth)
    if (x < endX) {
      ctx.beginPath()
      ctx.moveTo(x, startY)
      ctx.lineTo(x, endY)
      ctx.stroke()
    }
  }

  // Horizontal lines
  for (let i = 1; i < rows; i++) {
    const y = startY + (i * cellHeight)
    if (y < endY) {
      ctx.beginPath()
      ctx.moveTo(startX, y)
      ctx.lineTo(endX, y)
      ctx.stroke()
    }
  }

  ctx.globalAlpha = 1.0
}

// Pan controls
const handleKeyDown = (e) => {
  // Ignore inputs and textareas
  if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) return

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

// Expose zoom methods for parent controls
defineExpose({
  zoomIn: () => {
    if (!canvasRef.value) return
    const centerX = canvasRef.value.width / 2
    const centerY = canvasRef.value.height / 2
    zoomCamera(-100, centerX, centerY)
  },
  zoomOut: () => {
    if (!canvasRef.value) return
    const centerX = canvasRef.value.width / 2
    const centerY = canvasRef.value.height / 2
    zoomCamera(100, centerX, centerY)
  },
  getZoom: () => camera.value.zoom
})

onUnmounted(() => {
  if (animationFrameId) cancelAnimationFrame(animationFrameId)
  window.removeEventListener('keydown', handleKeyDown)
  window.removeEventListener('keyup', handleKeyUp)
  cleanup()
})
</script>

<style scoped>
canvas {
  display: block;
}
</style>
