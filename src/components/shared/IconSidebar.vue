<script setup>
import { computed } from 'vue'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { Button } from '@/components/ui/button'

const props = defineProps({
  items: {
    type: Array,
    required: true,
    // Format: [{ id: 'assets', icon: ImageIcon, label: 'Assets', badge: 5 }]
  },
  activeItem: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['select'])

const handleSelect = (itemId) => {
  emit('select', itemId)
}
</script>

<template>
  <aside class="fixed left-0 top-0 h-screen w-16 bg-lumina-card border-r border-lumina-border flex flex-col items-center py-4 gap-2 z-50">
    
    <!-- Logo/Home -->
    <div class="mb-4 p-2 rounded-lg bg-lumina-detail text-lumina-bg">
      <div class="h-6 w-6 font-bold font-serif text-sm flex items-center justify-center">L</div>
    </div>

    <div class="h-px w-10 bg-lumina-border mb-2"></div>

    <!-- Menu Items -->
    <TooltipProvider>
      <div 
        v-for="item in items" 
        :key="item.id"
        class="relative">
        
        <Tooltip :delay-duration="200">
          <TooltipTrigger as-child>
            <Button
              variant="ghost"
              size="icon"
              :class="[
                'relative h-11 w-11 rounded-lg transition-all',
                activeItem === item.id 
                  ? 'bg-lumina-detail/10 text-lumina-detail border border-lumina-detail/20' 
                  : 'text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg'
              ]"
              @click="handleSelect(item.id)">
              <component :is="item.icon" class="h-5 w-5" />
              
              <!-- Badge -->
            </Button>
          </TooltipTrigger>
          
          <TooltipContent side="right" class="bg-lumina-bg border-lumina-border text-lumina-text">
            <p class="text-xs font-medium">{{ item.label }}</p>
          </TooltipContent>
        </Tooltip>
      </div>
    </TooltipProvider>

    <!-- Spacer -->
    <div class="flex-1"></div>

    <!-- Bottom Actions (Settings, etc) -->
    <div class="h-px w-10 bg-lumina-border mb-2"></div>
    
    <slot name="bottom" />
  </aside>
</template>
