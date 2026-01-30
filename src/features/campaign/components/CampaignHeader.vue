<template>
  <header class="flex h-12 items-center justify-between border-b border-lumina-border px-4 bg-lumina-bg shrink-0">
      
      <!-- Left: Sidebar Toggle -->
      <div class="flex items-center gap-3">
         <Button 
            variant="ghost" 
            size="icon-sm" 
            class="md:hidden text-lumina-text-muted hover:text-lumina-text" 
            @click="$emit('toggle-sidebar')">
            <Menu class="h-4 w-4" />
         </Button>
      </div>

      <!-- Right: Controls -->
      <div class="flex items-center gap-1.5">
         
         <!-- View Modes -->
         <div class="flex items-center bg-lumina-card rounded-lg p-0.5 border border-lumina-border">
            <Button 
               :variant="viewMode === 'grid' ? 'secondary' : 'ghost'"
               size="icon-sm"
               class="h-7 w-7 rounded-md"
               :class="viewMode === 'grid' ? 'bg-lumina-bg shadow-sm text-lumina-text' : 'text-lumina-text-muted hover:text-lumina-text'"
               @click="$emit('update:viewMode', 'grid')"
               title="Grid View">
               <LayoutGrid class="h-3.5 w-3.5" />
            </Button>
            <Button 
               :variant="viewMode === 'small' ? 'secondary' : 'ghost'"
               size="icon-sm"
               class="h-7 w-7 rounded-md"
               :class="viewMode === 'small' ? 'bg-lumina-bg shadow-sm text-lumina-text' : 'text-lumina-text-muted hover:text-lumina-text'"
               @click="$emit('update:viewMode', 'small')"
               title="Compact View">
               <Grid class="h-3.5 w-3.5" />
            </Button>
         </div>

         <div class="h-4 w-px bg-lumina-border mx-1.5"></div>

         <!-- Blur Toggle -->
         <Button 
            :variant="blurMode ? 'warning' : 'ghost'"
            size="sm"
            class="h-7 text-xs font-medium gap-1.5"
            :class="blurMode ? 'bg-amber-500/10 text-amber-500 border-amber-500/20 hover:bg-amber-500/20' : 'text-lumina-text-muted hover:text-lumina-text'"
            @click="$emit('toggle-blur')">
            <component :is="blurMode ? Eye : EyeOff" class="h-3.5 w-3.5" />
            <span>{{ blurMode ? 'Hidden' : 'Visible' }}</span>
         </Button>

         <div class="h-4 w-px bg-lumina-border mx-1.5"></div>

         <!-- Stats -->
         <div class="text-[10px] uppercase tracking-wider text-lumina-text-muted font-medium px-2">
            {{ assetsCount }} items
         </div>

      </div>
  </header>
</template>

<script setup>
import { 
   Menu, 
   LayoutGrid, 
   Grid, 
   Eye, 
   EyeOff 
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

defineProps({
   viewMode: String,
   blurMode: Boolean,
   assetsCount: Number,
   isSidebarOpen: Boolean
})

defineEmits(['toggle-sidebar', 'update:viewMode', 'toggle-blur'])
</script>
