<script setup>
// Separate script block for component import if needed or just use setup?
// Just use setup.
import DiceRollResult from './DiceRollResult.vue'
import ChatCard from './ChatCard.vue'
import { computed } from 'vue'
import { Trash2, Sword } from 'lucide-vue-next'


const props = defineProps({
  message: {
    type: Object,
    required: true
  },
  isOwner: {
    type: Boolean,
    default: false
  },
  currentUserId: {
    type: String,
    required: true
  },

  senderName: {
    type: String,
    default: 'Desconhecido'
  },
  isCapturing: {
    type: Boolean,
    default: false
  },
  selectable: {
    type: Boolean,
    default: false
  },
  selected: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['delete', 'roll-damage', 'add-initiative', 'toggle-select'])

const isMe = computed(() => props.message.user_id === props.currentUserId)
const isPrivate = computed(() => !!props.message.recipient_id)

const canDelete = computed(() => {
  return isMe.value || props.isOwner
})

const formatTime = (isoString) => {
  return new Date(isoString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const parsedContent = computed(() => {
  if (!props.message.content || !props.message.content.startsWith('{')) return null
  try {
    const parsed = JSON.parse(props.message.content)
    return parsed.type ? parsed : null
  } catch (e) {
    return null
  }
})
</script>

<template>
  <div @click="selectable && parsedContent?.type === 'roll' ? $emit('toggle-select', message.id) : null"
    class="w-full rounded-lg p-5 mb-4 relative group transition-all duration-300 border backdrop-blur-sm" :class="[
      isMe
        ? 'bg-gradient-to-br from-lumina-card via-lumina-card to-lumina-detail/5 border-lumina-detail/30 hover:border-lumina-detail/50'
        : 'bg-lumina-card border-lumina-border hover:border-lumina-border/80',
      parsedContent?.subtype === 'spell' ? 'shadow-[0_0_20px_-10px_rgba(59,130,246,0.15)] !border-blue-500/20' : '',
      parsedContent?.subtype === 'attack' ? 'shadow-[0_0_20px_-10px_rgba(239,68,68,0.15)] !border-red-500/20' : '',
      selectable ? 'cursor-pointer' : '',
      selected ? '!border-lumina-detail ring-1 ring-lumina-detail bg-lumina-detail/10' : ''
    ]">

    <!-- Header -->
    <div class="flex items-center justify-between mb-4 pb-3 border-b border-lumina-border/50">
      <div class="flex items-center gap-3">
        <!-- Avatar Placeholder -->
        <div class="h-8 w-8 rounded-full flex items-center justify-center shrink-0 border"
          :class="isMe ? 'bg-lumina-detail/10 border-lumina-detail/30 text-lumina-detail' : 'bg-lumina-bg border-lumina-border text-lumina-text-muted'">
          <span class="text-xs font-bold font-serif">{{ senderName.charAt(0).toUpperCase() }}</span>
        </div>

        <div class="flex flex-col">
          <span class="text-xs font-bold font-serif tracking-wide"
            :class="isMe ? 'text-lumina-detail' : 'text-lumina-text'">
            {{ senderName }}
          </span>
          <span v-if="parsedContent?.type === 'roll'"
            class="text-[10px] text-lumina-text-muted font-mono uppercase tracking-wider">
            Rolou Dados
          </span>
        </div>
      </div>

      <div class="flex items-center gap-4">
        <span v-if="isPrivate"
          class="text-[10px] uppercase font-bold text-purple-400 bg-purple-500/10 px-1.5 py-0.5 rounded border border-purple-500/20 shadow-[0_0_10px_-4px_rgba(168,85,247,0.3)]">Sussurro</span>

        <span class="text-xs text-lumina-text-muted font-sans opacity-60">
          {{ new Date(message.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }}
        </span>

        <!-- Action Area -->
        <div v-if="!selectable"
          class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity bg-lumina-bg/80 rounded-md border border-lumina-border/50 px-1 py-0.5 shadow-sm absolute right-4 -top-3 sm:static sm:bg-transparent sm:border-0 sm:shadow-none sm:p-0">
          <button v-if="parsedContent?.type === 'roll' && isCapturing"
            @click.stop="$emit('add-initiative', { name: senderName, total: parsedContent.total })"
            class="p-1.5 rounded hover:bg-lumina-detail/10 text-lumina-text-muted hover:text-lumina-detail transition-colors"
            title="Adicionar à Iniciativa">
            <Sword class="h-3.5 w-3.5" />
          </button>

          <button v-if="canDelete" @click.stop="$emit('delete', message.id)"
            class="p-1.5 rounded hover:bg-red-500/10 text-lumina-text-muted hover:text-red-400 transition-colors"
            title="Excluir mensagem">
            <Trash2 class="h-3.5 w-3.5" />
          </button>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="text-lumina-text text-sm leading-6 px-1 font-sans">
      <!-- Type: Roll -->
      <DiceRollResult v-if="parsedContent && parsedContent.type === 'roll'" :result="parsedContent"
        @roll-damage="$emit('roll-damage', $event)" />

      <!-- Type: Card -->
      <ChatCard v-else-if="parsedContent && parsedContent.type === 'card'" :card="parsedContent" />

      <!-- Type: Text -->
      <p v-else class="whitespace-pre-wrap break-words text-lumina-text/90 px-2">{{ message.content }}</p>
    </div>

  </div>
</template>
