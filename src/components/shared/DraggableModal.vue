<script setup>
import { ref, computed, onMounted } from 'vue'
import { X, Minimize2, Maximize2, GripHorizontal } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

const props = defineProps({
  title: { type: String, required: true },
  icon: { type: [Object, Function], default: null }, // Accept both for Lucide icons
  defaultWidth: { type: Number, default: 600 },
  defaultHeight: { type: Number, default: 400 },
  minWidth: { type: Number, default: 300 },
  minHeight: { type: Number, default: 200 },
  modelValue: { type: Boolean, default: true },
  zIndex: { type: Number, default: 100 }
})

const emit = defineEmits(['update:modelValue', 'close', 'focus'])

// Modal state
const modalRef = ref(null)
const headerRef = ref(null)
const isMinimized = ref(false)
const isMaximized = ref(false)
const width = ref(props.defaultWidth)
const height = ref(props.defaultHeight)
const position = ref({ x: 0, y: 0 })

// Dragging state
const isDragging = ref(false)
const dragStart = ref({ x: 0, y: 0 })

// Center modal on mount
onMounted(() => {
  if (modalRef.value) {
    position.value = {
      x: (window.innerWidth - props.defaultWidth) / 2,
      y: (window.innerHeight - props.defaultHeight) / 2
    }
  }
})

// Computed styles
const modalStyle = computed(() => {
  if (isMaximized.value) {
    return {
      width: '100vw',
      height: '100vh',
      left: '0px',
      top: '0px',
      zIndex: props.zIndex
    }
  }
  
  return {
    width: `${width.value}px`,
    height: isMinimized.value ? 'auto' : `${height.value}px`,
    left: `${position.value.x}px`,
    top: `${position.value.y}px`,
    zIndex: props.zIndex
  }
})

// Drag handlers
const startDrag = (e) => {
  if (isMaximized.value) return
  isDragging.value = true
  dragStart.value = {
    x: e.clientX - position.value.x,
    y: e.clientY - position.value.y
  }
  emit('focus')
  
  document.addEventListener('mousemove', onDrag)
  document.addEventListener('mouseup', stopDrag)
}

const onDrag = (e) => {
  if (!isDragging.value) return
  position.value = {
    x: e.clientX - dragStart.value.x,
    y: e.clientY - dragStart.value.y
  }
}

const stopDrag = () => {
  isDragging.value = false
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
}

// Actions
const close = () => {
  emit('update:modelValue', false)
  emit('close')
}

const toggleMinimize = () => {
  isMinimized.value = !isMinimized.value
}

const toggleMaximize = () => {
  isMaximized.value = !isMaximized.value
}

const handleFocus = () => {
  emit('focus')
}

// Resize handle
const isResizing = ref(false)
const startResize = (e) => {
  if (isMaximized.value) return
  isResizing.value = true
  const startX = e.clientX
  const startY = e.clientY
  const startWidth = width.value
  const startHeight = height.value

  const onMouseMove = (e) => {
    const deltaX = e.clientX - startX
    const deltaY = e.clientY - startY
    width.value = Math.max(props.minWidth, startWidth + deltaX)
    height.value = Math.max(props.minHeight, startHeight + deltaY)
  }

  const onMouseUp = () => {
    isResizing.value = false
    document.removeEventListener('mousemove', onMouseMove)
    document.removeEventListener('mouseup', onMouseUp)
  }

  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)
}
</script>

<template>
  <div 
    v-if="modelValue"
    ref="modalRef"
    class="fixed bg-lumina-card border border-lumina-border rounded-xl shadow-2xl flex flex-col overflow-hidden"
    :style="modalStyle"
    @mousedown="handleFocus">
    
    <!-- Header (Draggable) -->
    <div 
      ref="headerRef"
      class="flex items-center justify-between px-4 py-2.5 border-b border-lumina-border bg-lumina-bg/50 cursor-move select-none shrink-0"
      @mousedown="startDrag">
      
      <div class="flex items-center gap-2">
        <component v-if="icon" :is="icon" class="h-4 w-4 text-lumina-detail" />
        <h3 class="text-sm font-semibold text-lumina-text font-serif">{{ title }}</h3>
        <GripHorizontal class="h-3 w-3 text-lumina-text-muted ml-1" />
      </div>

      <div class="flex items-center gap-1">
        <Button 
          variant="ghost" 
          size="icon-sm"
          class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text"
          @click.stop="toggleMinimize">
          <Minimize2 class="h-3 w-3" />
        </Button>
        <Button 
          variant="ghost" 
          size="icon-sm"
          class="h-6 w-6 text-lumina-text-muted hover:text-lumina-text"
          @click.stop="toggleMaximize">
          <Maximize2 class="h-3 w-3" />
        </Button>
        <Button 
          variant="ghost" 
          size="icon-sm"
          class="h-6 w-6 text-lumina-text-muted hover:text-red-400"
          @click.stop="close">
          <X class="h-3 w-3" />
        </Button>
      </div>
    </div>

    <!-- Content -->
    <div v-show="!isMinimized" class="flex-1 overflow-auto p-4 bg-lumina-card">
      <slot />
    </div>

    <!-- Resize Handle -->
    <div 
      v-show="!isMinimized && !isMaximized"
      class="absolute bottom-0 right-0 w-4 h-4 cursor-se-resize"
      @mousedown.stop="startResize">
      <div class="absolute bottom-1 right-1 w-2 h-2 border-r-2 border-b-2 border-lumina-border"></div>
    </div>
  </div>
</template>
