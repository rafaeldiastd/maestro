<template>
   <aside :class="[
      'flex flex-col border-r border-border bg-card transition-all duration-300 overflow-hidden',
      isOpen ? 'w-full md:w-64' : 'w-0 border-none'
   ]">

      <!-- Header / Nav -->
      <div class="p-4 border-b border-lumina-border shrink-0">
         <button
            class="flex items-center text-xs font-medium text-lumina-text-muted hover:text-lumina-text transition-colors mb-4 group"
            @click="$emit('back')">
            <ArrowLeft class="mr-2 h-3 w-3 group-hover:-translate-x-0.5 transition-transform" />
            DASHBOARD
         </button>

         <div class="space-y-1">
            <h1
               class="text-lg font-bold font-serif tracking-tight text-lumina-text break-words leading-tight line-clamp-2">
               {{ sessionName || 'Untitled Session' }}
            </h1>
            <span class="text-[10px] uppercase tracking-widest text-lumina-text-muted font-medium">Explorer</span>
         </div>
      </div>

      <!-- Scrollable Content -->
      <ScrollArea class="flex-1 p-4">
         <div class="space-y-6">

            <!-- Upload Zone (Minimalist) -->
            <div
               class="group relative flex h-24 w-full cursor-pointer flex-col items-center justify-center rounded-md border border-dashed border-lumina-border bg-lumina-bg/30 transition-all hover:border-lumina-detail hover:bg-lumina-bg/50"
               :class="isUploading ? 'pointer-events-none opacity-50' : ''" @click="$refs.fileInput.click()"
               @dragover.prevent @drop.prevent="handleDrop">
               <input type="file" ref="fileInput" class="hidden" multiple accept="image/*" @change="handleFileSelect" />

               <div class="text-center space-y-1">
                  <div
                     class="p-1.5 rounded-md bg-lumina-card border border-lumina-border inline-flex text-lumina-text-muted group-hover:text-lumina-text transition-colors">
                     <UploadCloud class="h-3.5 w-3.5" />
                  </div>
                  <p
                     class="text-[10px] font-medium text-lumina-text-muted group-hover:text-lumina-accent transition-colors">
                     {{ isUploading ? 'Uploading...' : 'Drop images' }}
                  </p>
               </div>
            </div>

            <!-- Session Info -->
            <div class="space-y-4">
               <h3 class="text-xs font-semibold uppercase tracking-wider text-muted-foreground flex items-center gap-2">
                  <Link class="h-3 w-3" />
                  Quick Links
               </h3>

               <div class="grid gap-3">
                  <div class="space-y-1.5">
                     <Label class="text-xs text-muted-foreground">Player Link</Label>
                     <Button variant="outline"
                        class="w-full justify-between bg-muted/50 border-border text-muted-foreground hover:text-foreground hover:bg-muted h-9 text-xs"
                        @click="$emit('copy-join')">
                        <span class="truncate max-w-[120px]">Join Session</span>
                        <component :is="linkJoinCopied ? Check : Copy" class="h-3 w-3 ml-2 shrink-0"
                           :class="linkJoinCopied ? 'text-green-500' : ''" />
                     </Button>
                  </div>

                  <div class="space-y-1.5">
                     <Label class="text-xs text-muted-foreground">Stream Overlay</Label>
                     <Button variant="outline"
                        class="w-full justify-between bg-muted/50 border-border text-muted-foreground hover:text-foreground hover:bg-muted h-9 text-xs"
                        @click="$emit('copy-stream')">
                        <span class="truncate max-w-[120px]">OBS / Browser</span>
                        <component :is="linkCopied ? Check : Copy" class="h-3 w-3 ml-2 shrink-0"
                           :class="linkCopied ? 'text-green-500' : ''" />
                     </Button>
                  </div>
               </div>
            </div>

            <Separator class="bg-border" />

            <!-- Danger Zone -->
            <div class="space-y-4">
               <h3 class="text-xs font-semibold uppercase tracking-wider text-destructive/80 flex items-center gap-2">
                  Danger Zone
               </h3>
               <Button variant="destructive"
                  class="w-full justify-start bg-destructive/10 text-destructive hover:bg-destructive/20 hover:text-destructive border border-destructive/20"
                  @click="$emit('end-session')">
                  <Trash2 class="mr-2 h-4 w-4" />
                  End Session
               </Button>
            </div>

         </div>
      </ScrollArea>
   </aside>
</template>

<script setup>
import {
   ArrowLeft,
   UploadCloud,
   Link,
   Copy,
   Check,
   Trash2
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Label } from '@/components/ui/label'

defineProps({
   isOpen: Boolean,
   sessionName: String,
   sessionId: String,
   isUploading: Boolean,
   uploadStatus: String,
   linkCopied: Boolean,
   linkJoinCopied: Boolean
})

defineEmits([
   'back',
   'file-change',
   'file-drop',
   'copy-join',
   'copy-stream',
   'end-session'
])
</script>
