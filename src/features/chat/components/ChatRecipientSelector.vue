<script setup>
import { computed } from 'vue'
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

const props = defineProps({
  members: {
    type: Array,
    required: true
  },
  modelValue: {
    type: String, // recipient_id or null
    default: null
  },
  currentUser: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const selectedRecipient = computed({
  get: () => props.modelValue || "everyone", // Use string "everyone" for null value handling in Select
  set: (val) => emit('update:modelValue', val === "everyone" ? null : val)
})

const recipientOptions = computed(() => {
  return props.members.filter(m => m.user_id !== props.currentUser?.id)
})
</script>

<template>
  <Select v-model="selectedRecipient">
    <SelectTrigger
      class="w-full h-8 text-xs bg-lumina-bg border-lumina-border text-lumina-text focus:ring-lumina-detail">
      <SelectValue placeholder="Para: Todos" />
    </SelectTrigger>
    <SelectContent class="bg-lumina-card border-lumina-border text-lumina-text z-[110]">
      <SelectGroup>
        <SelectLabel class="text-xs text-lumina-text-muted">Destinatários</SelectLabel>
        <SelectItem value="everyone" class="text-xs focus:bg-lumina-detail/20 focus:text-lumina-text cursor-pointer">
          Todos (Público)
        </SelectItem>
        <SelectItem v-for="member in recipientOptions" :key="member.user_id" :value="member.user_id"
          class="text-xs focus:bg-lumina-detail/20 focus:text-lumina-text cursor-pointer">
          {{ (member.email || 'Desconhecido').split('@')[0] }} {{ member.role === 'master' ? '(Mestre)' : '' }}
        </SelectItem>
      </SelectGroup>
    </SelectContent>
  </Select>
</template>
