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
        <SelectTrigger class="w-[140px] h-8 text-xs bg-background border-border text-foreground focus:ring-primary">
            <div class="flex items-center gap-2">
                <Dices class="h-3.5 w-3.5 text-primary" />
                <SelectValue placeholder="Rolagens" />
            </div>
        </SelectTrigger>
        <SelectContent class="bg-popover border-border text-popover-foreground z-[110]">
            <SelectGroup>
                <SelectLabel class="text-xs text-muted-foreground">Escolha um Dado</SelectLabel>
                <SelectItem v-for="die in ['d4', 'd6', 'd8', 'd10', 'd12', 'd20', 'd100']" :key="die" :value="'1' + die"
                    class="text-xs font-mono cursor-pointer focus:bg-accent focus:text-accent-foreground">
                    {{ die }}
                </SelectItem>
            </SelectGroup>
        </SelectContent>
    </Select>
</template>
