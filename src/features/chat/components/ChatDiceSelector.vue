<script setup>
import {
    Select,
    SelectContent,
    SelectGroup,
    SelectItem,
    SelectLabel,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
import { Dices } from 'lucide-vue-next'

const emit = defineEmits(['roll'])

const handleValueChange = (value) => {
    if (value) {
        emit('roll', value)
    }
}
</script>

<template>
    <Select :model-value="''" @update:model-value="handleValueChange">
        <SelectTrigger
            class="w-[140px] h-8 text-xs bg-lumina-bg border-lumina-border text-lumina-text focus:ring-lumina-detail">
            <div class="flex items-center gap-2">
                <Dices class="h-3.5 w-3.5 text-lumina-detail" />
                <SelectValue placeholder="Rolagens" />
            </div>
        </SelectTrigger>
        <SelectContent class="bg-lumina-card border-lumina-border text-lumina-text z-[110]">
            <SelectGroup>
                <SelectLabel class="text-xs text-lumina-text-muted">Escolha um Dado</SelectLabel>
                <SelectItem v-for="die in ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100']" :key="die" :value="'1' + die"
                    class="text-xs font-mono cursor-pointer focus:bg-lumina-detail/20 focus:text-lumina-text">
                    {{ die }}
                </SelectItem>
            </SelectGroup>
        </SelectContent>
    </Select>
</template>
