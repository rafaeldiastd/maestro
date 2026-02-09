<script setup>
import { computed } from 'vue'
import { User, Sheet, LogOut } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

const props = defineProps({
    character: {
        type: Object,
        default: null
    },
    isConnected: {
        type: Boolean,
        default: false
    }
})

const emit = defineEmits(['open-sheet', 'logout'])

const characterName = computed(() => props.character?.name || 'Criar Personagem')
</script>

<template>
    <nav
        class="fixed top-0 left-0 right-0 h-16 bg-lumina-bg/80 backdrop-blur-md border-b border-lumina-border z-40 px-4 md:px-8 flex items-center justify-between">

        <!-- Left: Brand / Status -->
        <div class="flex items-center gap-3">
            <div
                class="h-8 w-8 bg-lumina-detail text-lumina-bg rounded-lg flex items-center justify-center font-serif font-bold text-xl">
                M
            </div>
            <div class="flex flex-col">
                <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Maestro</span>
                <div class="flex items-center gap-1.5">
                    <div class="h-1.5 w-1.5 rounded-full"
                        :class="isConnected ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]' : 'bg-yellow-500 animate-pulse'">
                    </div>
                    <span class="text-[0.625rem] font-medium text-lumina-text-muted uppercase tracking-wider">
                        {{ isConnected ? 'Conectado' : 'Conectando...' }}
                    </span>
                </div>
            </div>
        </div>

        <!-- Center: Character Actions -->
        <div class="absolute left-1/2 -translate-x-1/2 flex items-center gap-2">
            <Button variant="ghost"
                class="h-10 px-4 gap-2 text-lumina-text hover:text-lumina-detail hover:bg-lumina-detail/10 border border-transparent hover:border-lumina-detail/20 transition-all group"
                @click="$emit('open-sheet')">
                <div class="relative">
                    <User class="h-4 w-4" />
                    <div v-if="!character"
                        class="absolute -top-1 -right-1 h-2 w-2 bg-lumina-detail rounded-full animate-ping"></div>
                </div>
                <span class="font-serif font-bold text-sm">{{ characterName }}</span>
            </Button>
        </div>

        <!-- Right: Actions -->
        <div class="flex items-center gap-2">
            <!-- Future: Settings, etc. -->
        </div>

    </nav>
</template>
