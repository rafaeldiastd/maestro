<template>
  <div class="absolute inset-0 pointer-events-none">
    <!-- Grid Frame Rectangle -->
    <div
      class="absolute border-2 border-lumina-detail pointer-events-auto cursor-move"
      :style="{
        left: frame.x + 'px',
        top: frame.y + 'px',
        width: frame.width + 'px',
        height: frame.height + 'px',
        boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.3)'
      }"
      @mousedown="startDrag"
    >
      <!-- Corner Handles -->
      <div
        v-for="corner in corners"
        :key="corner.position"
        class="absolute w-3 h-3 bg-lumina-detail border border-lumina-bg rounded-sm cursor-pointer hover:scale-125 transition-transform"
        :class="corner.cursor"
        :style="corner.style"
        @mousedown.stop="startResize(corner.position)"
      ></div>

      <!-- Edge Handles -->
      <div
        v-for="edge in edges"
        :key="edge.position"
        class="absolute bg-lumina-detail/50 hover:bg-lumina-detail transition-colors cursor-pointer"
        :class="edge.cursor"
        :style="edge.style"
        @mousedown.stop="startResize(edge.position)"
      ></div>

      <!-- Info Label -->
      <div class="absolute -top-6 left-0 bg-lumina-detail text-lumina-bg px-2 py-1 rounded text-xs font-mono whitespace-nowrap">
        {{ Math.round(frame.width) }}×{{ Math.round(frame.height) }}px
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  initialFrame: {
    type: Object,
    default: () => ({ x: 50, y: 50, width: 700, height: 500 })
  },
  maxBounds: {
    type: Object,
    required: true // { width, height } of the image
  },
  zoom: {
    type: Number,
    default: 1
  },
  cameraOffset: {
    type: Object,
    default: () => ({ x: 0, y: 0 })
  }
})

const emit = defineEmits(['update:frame'])

const frame = ref({ ...props.initialFrame })
const isDragging = ref(false)
const isResizing = ref(false)
const resizeMode = ref(null)
const dragStart = ref({ x: 0, y: 0 })
const frameStart = ref({ x: 0, y: 0, width: 0, height: 0 })

// Corner positions
const corners = computed(() => [
  { position: 'nw', cursor: 'cursor-nw-resize', style: { top: '-6px', left: '-6px' } },
  { position: 'ne', cursor: 'cursor-ne-resize', style: { top: '-6px', right: '-6px' } },
  { position: 'sw', cursor: 'cursor-sw-resize', style: { bottom: '-6px', left: '-6px' } },
  { position: 'se', cursor: 'cursor-se-resize', style: { bottom: '-6px', right: '-6px' } }
])

// Edge positions
const edges = computed(() => [
  { position: 'n', cursor: 'cursor-n-resize', style: { top: '-2px', left: '10px', right: '10px', height: '4px' } },
  { position: 's', cursor: 'cursor-s-resize', style: { bottom: '-2px', left: '10px', right: '10px', height: '4px' } },
  { position: 'w', cursor: 'cursor-w-resize', style: { left: '-2px', top: '10px', bottom: '10px', width: '4px' } },
  { position: 'e', cursor: 'cursor-e-resize', style: { right: '-2px', top: '10px', bottom: '10px', width: '4px' } }
])

const startDrag = (e) => {
  isDragging.value = true
  dragStart.value = { x: e.clientX, y: e.clientY }
  frameStart.value = { ...frame.value }
  e.preventDefault()
}

const startResize = (mode) => {
  return (e) => {
    isResizing.value = true
    resizeMode.value = mode
    dragStart.value = { x: e.clientX, y: e.clientY }
    frameStart.value = { ...frame.value }
    e.preventDefault()
  }
}

const handleMouseMove = (e) => {
  if (!isDragging.value && !isResizing.value) return

  const deltaX = (e.clientX - dragStart.value.x) / props.zoom
  const deltaY = (e.clientY - dragStart.value.y) / props.zoom

  if (isDragging.value) {
    // Move entire frame
    frame.value.x = Math.max(0, Math.min(props.maxBounds.width - frame.value.width, frameStart.value.x + deltaX))
    frame.value.y = Math.max(0, Math.min(props.maxBounds.height - frame.value.height, frameStart.value.y + deltaY))
  } else if (isResizing.value) {
    // Resize based on mode
    const mode = resizeMode.value
    const newFrame = { ...frameStart.value }

    if (mode.includes('n')) {
      const newY = Math.max(0, frameStart.value.y + deltaY)
      const newHeight = frameStart.value.height - (newY - frameStart.value.y)
      if (newHeight > 50) {
        newFrame.y = newY
        newFrame.height = newHeight
      }
    }
    if (mode.includes('s')) {
      newFrame.height = Math.max(50, Math.min(props.maxBounds.height - frameStart.value.y, frameStart.value.height + deltaY))
    }
    if (mode.includes('w')) {
      const newX = Math.max(0, frameStart.value.x + deltaX)
      const newWidth = frameStart.value.width - (newX - frameStart.value.x)
      if (newWidth > 50) {
        newFrame.x = newX
        newFrame.width = newWidth
      }
    }
    if (mode.includes('e')) {
      newFrame.width = Math.max(50, Math.min(props.maxBounds.width - frameStart.value.x, frameStart.value.width + deltaX))
    }

    frame.value = newFrame
  }
}

const handleMouseUp = () => {
  if (isDragging.value || isResizing.value) {
    emit('update:frame', { ...frame.value })
  }
  isDragging.value = false
  isResizing.value = false
  resizeMode.value = null
}

onMounted(() => {
  window.addEventListener('mousemove', handleMouseMove)
  window.addEventListener('mouseup', handleMouseUp)
})

onUnmounted(() => {
  window.removeEventListener('mousemove', handleMouseMove)
  window.removeEventListener('mouseup', handleMouseUp)
})
</script>

<style scoped>
.cursor-nw-resize { cursor: nw-resize; }
.cursor-ne-resize { cursor: ne-resize; }
.cursor-sw-resize { cursor: sw-resize; }
.cursor-se-resize { cursor: se-resize; }
.cursor-n-resize { cursor: n-resize; }
.cursor-s-resize { cursor: s-resize; }
.cursor-w-resize { cursor: w-resize; }
.cursor-e-resize { cursor: e-resize; }
</style>
