<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch, computed } from 'vue'
import { storeToRefs } from 'pinia'
import { Send, X, MessageSquare, ChevronRight, ChevronLeft, Calculator, RotateCcw, Check, Copy } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { useChatStore } from '@/stores/chat'
import { useCampaignInvites } from '@/composables/useCampaignInvites'
import ChatMessage from './ChatMessage.vue'
import ChatRecipientSelector from './ChatRecipientSelector.vue'
import ChatDiceSelector from './ChatDiceSelector.vue'
import { useDiceRoll } from '@/composables/useDiceRoll'

// ...
const props = defineProps({
  campaignId: {
    type: String,
    required: true
  },
  currentUserId: {
    type: String,
    required: true
  },
  isOwner: {
    type: Boolean,
    default: false
  },
  isOpen: {
    type: Boolean,
    default: true
  },
  activeContext: {
    type: Object,
    default: null
  },
  isCapturing: {
    type: Boolean,
    default: false
  }
})



const emit = defineEmits(['toggle', 'add-initiative'])

// Sum/Calculator Mode State
const isSumming = ref(false)
const selectedMessageIds = ref(new Set())

const toggleSumMode = () => {
  isSumming.value = !isSumming.value
  selectedMessageIds.value.clear()
}

const toggleSelection = (msgId) => {
  if (selectedMessageIds.value.has(msgId)) {
    selectedMessageIds.value.delete(msgId)
  } else {
    selectedMessageIds.value.add(msgId)
  }
}

const selectionTotal = computed(() => {
  let total = 0
  selectedMessageIds.value.forEach(id => {
    const msg = messages.value.find(m => m.id === id)
    if (msg) {
      try {
        const data = JSON.parse(msg.content)
        if (data && data.total) {
          total += parseInt(data.total)
        }
      } catch (e) { }
    }
  })
  return total
})


// Composables
const chatStore = useChatStore()
const {
  messages,
  loading,
  hasMore
} = storeToRefs(chatStore)

const {
  loadMessages,
  loadMoreMessages,
  subscribeToChat,
  unsubscribeChat,
  sendMessage,
  deleteMessage
} = chatStore
const { roll } = useDiceRoll()
const { getMembers } = useCampaignInvites()

// State
const newMessage = ref('')
const members = ref([])
const selectedRecipient = ref(null)
const messagesContainer = ref(null)
const sending = ref(false)
const unreadCount = ref(0)
const lastSeenCount = ref(0)

// History
const msgHistory = ref([])
const historyIndex = ref(-1)

// Load Data
onMounted(async () => {
  const { data: membersData } = await getMembers(props.campaignId)
  if (membersData) members.value = membersData

  await loadMessages(props.campaignId)
  lastSeenCount.value = messages.value.length
  scrollToBottom()

  subscribeToChat(props.campaignId)
})

onUnmounted(() => {
  unsubscribeChat()
})

// Scroll
const scrollToBottom = () => {
  if (messagesContainer.value) messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
}

// Watchers
const handleScroll = async (e) => {
  const target = e.target
  if (target.scrollTop === 0 && !loading.value && hasMore.value) {
    const oldHeight = target.scrollHeight
    await loadMoreMessages(props.campaignId)
    // Restore scroll position
    nextTick(() => {
      target.scrollTop = target.scrollHeight - oldHeight
    })
  }
}

watch(() => messages.value.length, async (newCount, oldCount) => {
  if (loading.value) return

  await nextTick()
  if (messagesContainer.value) {
    // Force scroll to bottom for now as requested
    scrollToBottom()
  }
})

// Simplified approach: remove the GLOBAL scroll to bottom watcher and use specific calls.
// 1. On Mount -> loadMessages -> scrollToBottom()
// 2. On Send/Receive -> scrollToBottom() (if user is near bottom?)
// 3. On Load More -> handleScroll restores position.

// Existing watcher for unread count is fine.
watch(() => messages.value.length, (newCount, oldCount) => {
  if (!props.isOpen && newCount > oldCount) {
    unreadCount.value += (newCount - oldCount)
  }

  // Check if the change was an APPEND (new message)
  if (messages.value.length > 0 && oldCount > 0) {
    const lastOld = messages.value[oldCount - 1]
    // This logic is flawed if we pre-pend.
    // If we prepend 20 msgs, the previous last message is now at index 20 + oldLen - 1...
    // Let's just manually call scrollToBottom where appropriate (sendMessage, socket)
    // AND for initial load.
  }
})

watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    unreadCount.value = 0
    nextTick(scrollToBottom)
  }
})

const handleKeyDown = (e) => {
  if (msgHistory.value.length === 0) return

  if (e.key === 'ArrowUp') {
    e.preventDefault()
    if (historyIndex.value < msgHistory.value.length - 1) {
      historyIndex.value++
      newMessage.value = msgHistory.value[msgHistory.value.length - 1 - historyIndex.value]
    }
  } else if (e.key === 'ArrowDown') {
    e.preventDefault()
    if (historyIndex.value > -1) {
      historyIndex.value--
      if (historyIndex.value === -1) {
        newMessage.value = ''
      } else {
        newMessage.value = msgHistory.value[msgHistory.value.length - 1 - historyIndex.value]
      }
    }
  }
}

// Helper to resolve variables
const calculateModifier = (val) => Math.floor((val - 10) / 2)

const resolveVariables = (formula) => {
  // Debug Log
  // console.log('Resolving variables for:', formula, 'Context:', props.activeContext)

  if (!props.activeContext || !formula.includes('@')) return formula

  return formula.replace(/@(\w+)/g, (match, key) => {
    const lowerKey = key.toLowerCase()

    // 1. Check Modifiers (e.g. dexMod)
    if (lowerKey.endsWith('mod')) {
      const stat = lowerKey.replace('mod', '') // 'str'
      if (props.activeContext.stats) {
        // Try lowercase first (standard), then as-is (just in case)
        // Note: NPCModal uses lowercase keys (str, dex...)
        const val = props.activeContext.stats[stat]
        if (val !== undefined) {
          return calculateModifier(val)
        }
      }
    }

    // 2. Check Stats directly (e.g. dex)
    if (props.activeContext.stats) {
      const val = props.activeContext.stats[lowerKey]
      if (val !== undefined) return val
    }

    // 3. Check Top-level (e.g. hp, ac)
    const topVal = props.activeContext[lowerKey]
    if (topVal !== undefined) return topVal

    console.warn(`Variable @${key} not found in context`, props.activeContext)
    return match
  })
}

const handleSend = async () => {
  const content = newMessage.value.trim()
  if (!content || sending.value) return

  sending.value = true

  // Add to local history
  msgHistory.value.push(content)
  historyIndex.value = -1 // Reset history pointer

  newMessage.value = '' // Optimistic clear

  try {
    // Check for commands
    if (content.startsWith('/r ') || content.startsWith('/roll ') || content.startsWith('/init ') || content.startsWith('/iniciativa ')) {
      let formula = content
        .replace(/^\/(r|roll)\s+/, '')
        .replace(/^\/(init|iniciativa)\s+/, '')

      // Determine context
      let context = 'generic'
      if (content.startsWith('/init') || content.startsWith('/iniciativa')) {
        context = 'initiative'
      }

      // Resolve Variables
      formula = resolveVariables(formula)

      const rollResult = roll(formula, context === 'initiative' ? 'Iniciativa' : 'Rolagem', context)

      if (rollResult) {
        // Inject Author Name for Initiative Tracker
        if (props.activeContext && props.activeContext.name) {
          rollResult.name = props.activeContext.name
        } else {
          const me = members.value.find(m => m.user_id === props.currentUserId)
          rollResult.name = me ? (me.email?.split('@')[0]) : 'Você'
        }

        await sendMessage(props.campaignId, JSON.stringify(rollResult), selectedRecipient.value)
      } else {
        await sendMessage(props.campaignId, content + ' (Rolagem Inválida)', selectedRecipient.value)
      }
    } else {
      // Normal message
      await sendMessage(props.campaignId, content, selectedRecipient.value)
    }
  } catch (err) {
    console.error(err)
  } finally {
    sending.value = false
    scrollToBottom()
  }
}

const handleDelete = async (msgId) => {
  if (confirm('Excluir esta mensagem?')) {
    // Optimistic Update
    const prevMessages = [...messages.value]
    messages.value = messages.value.filter(m => m.id !== msgId)

    const result = await deleteMessage(msgId)
    if (!result.success) {
      // Revert if failed
      messages.value = prevMessages
      alert('Falha ao excluir mensagem')
    }
  }
}

// Helpers to resolve names
const getAuthorName = (userId) => {
  if (userId === props.currentUserId) return 'Você'
  const member = members.value.find(m => m.user_id === userId)
  return member ? (member.email?.split('@')[0] || 'Desconhecido') : 'Desconhecido'
}

const handleRollDamage = async (formula) => {
  try {
    let finalFormula = formula
    // Try to resolve variables if context is active
    if (props.activeContext) {
      finalFormula = resolveVariables(formula)
    }

    const rollResult = roll(finalFormula, 'Dano', 'damage')
    if (rollResult) {
      await sendMessage(props.campaignId, JSON.stringify(rollResult), selectedRecipient.value)
    }
  } catch (e) {
    console.error('Damage roll failed', e)
  }
}

const handleQuickRoll = async (formula) => {
  try {
    const rollResult = roll(formula, 'Rolagem Rápida', 'generic')
    if (rollResult) {
      await sendMessage(props.campaignId, JSON.stringify(rollResult), selectedRecipient.value)
    }
  } catch (e) {
    console.error('Quick roll failed', e)
  }
}

</script>

<template>
  <div class="fixed right-0 top-0 bottom-0 z-[100] flex flex-col transition-all duration-300 pointer-events-none"
    :class="isOpen ? 'w-96 translate-x-0' : 'w-0 translate-x-0'">
    <!-- Main Sidebar Content -->
    <div v-show="isOpen"
      class="flex-1 flex flex-col bg-card border-l border-border shadow-2xl pointer-events-auto h-full">

      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-card">
        <div class="flex items-center gap-2">
          <MessageSquare class="h-4 w-4 text-lumina-detail" />
          <span class="text-sm font-bold text-lumina-text font-serif tracking-wide">Chat do Grupo</span>
        </div>
        <div
          class="text-[10px] uppercase font-bold text-lumina-text-muted tracking-wider bg-lumina-bg px-2 py-1 rounded border border-lumina-border">
          {{ members.length }} Online
        </div>
      </div>

      <!-- Messages Area -->
      <div ref="messagesContainer" class="flex-1 overflow-y-auto p-4 scrollbar-thin" @scroll="handleScroll">
        <div v-if="loading && messages.length > 0" class="flex justify-center py-2">
          <div class="h-4 w-4 animate-spin rounded-full border-2 border-lumina-detail border-t-transparent"></div>
        </div>
        <div v-if="loading && messages.length === 0" class="flex h-full items-center justify-center">
          <div class="h-5 w-5 animate-spin rounded-full border-2 border-lumina-detail border-t-transparent"></div>
        </div>

        <div v-else-if="messages.length === 0"
          class="flex h-full flex-col items-center justify-center opacity-50 space-y-2">
          <MessageSquare class="h-10 w-10 text-lumina-text-muted" />
          <p class="text-xs text-lumina-text-muted">Nenhuma mensagem ainda.</p>
        </div>

        <div v-else class="space-y-4">
          <!-- Date separators could be added here in future -->
          <ChatMessage v-for="msg in messages" :key="msg.id" :message="msg" :senderName="getAuthorName(msg.user_id)"
            :currentUserId="currentUserId" :isOwner="isOwner" :is-capturing="isCapturing" :selectable="isSumming"
            :selected="selectedMessageIds.has(msg.id)" @delete="handleDelete" @roll-damage="handleRollDamage"
            @add-initiative="$emit('add-initiative', $event)" @toggle-select="toggleSelection" />
        </div>
      </div>

      <!-- Footer Area: Input & Recipient -->
      <div class="shrink-0 p-4 border-t border-lumina-border bg-card space-y-3">

        <!-- Toolbar: Recipient & Dice -->
        <div class="flex items-center gap-2">
          <!-- Recipient -->
          <div class="flex-1 min-w-0">
            <ChatRecipientSelector v-model="selectedRecipient" :members="members"
              :currentUser="{ id: currentUserId }" />
          </div>

          <!-- Separator -->
          <div class="w-px h-6 bg-lumina-border/50"></div>

          <!-- Quick Dice -->
          <ChatDiceSelector @roll="handleQuickRoll" />

          <!-- Separator -->
          <div class="w-px h-6 bg-lumina-border/50"></div>

          <!-- Calculator Toggle -->
          <Button size="icon" class="h-8 w-8 transition-all duration-300"
            :class="isSumming ? 'bg-lumina-detail text-lumina-bg' : 'text-lumina-text-muted hover:text-lumina-text hover:bg-lumina-bg'"
            @click="toggleSumMode" title="Modo Calculadora">
            <Calculator class="h-4 w-4" />
          </Button>
        </div>

        <!-- Calculator Display (Floating) -->
        <div v-if="isSumming"
          class="absolute left-4 right-4 -top-16 bg-lumina-card border border-lumina-detail shadow-lg shadow-lumina-detail/10 rounded-lg p-2 flex items-center justify-between z-50 animate-in fade-in slide-in-from-bottom-2">
          <div class="flex items-center gap-2 text-xs">
            <span class="font-bold text-lumina-text-muted uppercase tracking-wider">Selecionados: {{
              selectedMessageIds.size }}</span>
          </div>

          <div class="flex items-center gap-3">
            <div class="h-4 w-px bg-border"></div>
            <Button size="icon" class="h-6 w-6 hover:bg-muted text-muted-foreground hover:text-destructive"
              @click="selectedMessageIds.clear()" title="Limpar Seleção">
              <RotateCcw class="h-3 w-3" />
            </Button>
          </div>
        </div>

        <!-- Input Form -->
        <form @submit.prevent="handleSend" class="relative flex gap-2">
          <Input v-model="newMessage" placeholder="Digite sua mensagem... (/r 1d20)" @keydown="handleKeyDown"
            class="flex-1 h-10 text-sm bg-lumina-bg border-lumina-border focus-visible:ring-lumina-detail pr-10 rounded-lg shadow-inner" />
          <Button type="submit" size="icon" :disabled="!newMessage.trim() || sending"
            class="absolute right-1 top-1 h-8 w-8 bg-lumina-detail text-lumina-bg hover:bg-lumina-detail/90 rounded-md transition-all hover:scale-105 active:scale-95">
            <Send class="h-4 w-4" />
          </Button>
        </form>
      </div>

    </div>
  </div>
</template>

<style scoped>
/* Scoped styles removed */
</style>
