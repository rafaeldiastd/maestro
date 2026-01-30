<script setup>
import { ref, computed } from 'vue'
import { Plus, Search, Skull, MoreVertical, Trash2, Pencil, X } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import {
   DropdownMenu,
   DropdownMenuContent,
   DropdownMenuItem,
   DropdownMenuLabel,
   DropdownMenuSeparator,
   DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

const props = defineProps({
   npcs: { type: Array, default: () => [] },
   viewMode: { type: String, default: 'grid' }
})

const emit = defineEmits(['create', 'edit', 'delete', 'close', 'select'])

const searchQuery = ref('')

const filteredNpcs = computed(() => {
   if (!searchQuery.value) return props.npcs
   const q = searchQuery.value.toLowerCase()
   return props.npcs.filter(npc => npc.name.toLowerCase().includes(q))
})

</script>

<template>
   <div class="flex flex-col h-full">
      <!-- Header -->
      <div class="p-4 border-b border-lumina-border shrink-0 space-y-3 bg-lumina-bg/50">
         <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
               <h2 class="text-sm font-bold font-serif text-lumina-text tracking-wide flex items-center gap-2">
                  <Skull class="h-4 w-4 text-lumina-detail" />
                  Bestiário
               </h2>
            </div>
            <div class="flex items-center gap-1">
               <Button size="icon" variant="ghost" class="h-7 w-7 text-lumina-text-muted hover:text-lumina-text"
                  @click="$emit('close')">
                  <X class="h-4 w-4" />
               </Button>
            </div>
         </div>

         <div class="pt-2">
            <Button size="sm" class="w-full gap-1 bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90 font-bold"
               @click="$emit('create')">
               <Plus class="h-3 w-3" /> Criar Criatura
            </Button>
         </div>

         <div class="relative">
            <Search class="absolute left-2 top-2 h-3.5 w-3.5 text-lumina-text-muted" />
            <Input v-model="searchQuery" placeholder="Buscar criaturas..."
               class="pl-8 h-8 text-xs bg-lumina-bg border-lumina-border text-lumina-text focus-visible:ring-lumina-detail" />
         </div>
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-4 space-y-2">
         <div v-if="filteredNpcs.length === 0" class="text-center py-10 text-lumina-text-muted">
            <p class="text-xs">Nenhuma criatura encontrada.</p>
         </div>

         <div v-else class="grid grid-cols-1 gap-2">
            <div v-for="npc in filteredNpcs" :key="npc.id"
               class="group flex items-center gap-3 p-2 rounded-md border border-lumina-border bg-lumina-card hover:border-lumina-detail/50 transition-all cursor-pointer"
               @click="$emit('select', npc)">
               <!-- Avatar Placeholder -->
               <div
                  class="h-10 w-10 shrink-0 rounded bg-lumina-bg flex items-center justify-center text-lumina-text-muted font-bold text-xs border border-lumina-border">
                  {{ npc.name.charAt(0) }}
               </div>

               <div class="flex-1 min-w-0">
                  <h3 class="text-sm font-medium text-lumina-text truncate">{{ npc.name }}</h3>
                  <p class="text-[10px] text-lumina-text-muted truncate">
                     CR {{ npc.challenge_rating || '?' }} • {{ npc.hp || '?' }} HP
                  </p>
               </div>

               <DropdownMenu>
                  <DropdownMenuTrigger as-child>
                     <Button variant="ghost" size="icon"
                        class="h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity" @click.stop>
                        <MoreVertical class="h-3 w-3" />
                     </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" class="bg-lumina-card border-lumina-border text-lumina-text">
                     <DropdownMenuItem @click.stop="$emit('edit', npc)">
                        <Pencil class="mr-2 h-3 w-3" /> Editar
                     </DropdownMenuItem>
                     <DropdownMenuSeparator class="bg-lumina-border" />
                     <DropdownMenuItem @click.stop="$emit('delete', npc)"
                        class="text-red-400 focus:text-red-300 focus:bg-red-950/30">
                        <Trash2 class="mr-2 h-3 w-3" /> Excluir
                     </DropdownMenuItem>
                  </DropdownMenuContent>
               </DropdownMenu>
            </div>
         </div>
      </div>
   </div>
</template>
