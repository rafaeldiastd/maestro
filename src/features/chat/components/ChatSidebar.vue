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
import { useCharacter } from '@/composables/useCharacter'
import { supabase } from '@/lib/supabaseClient'

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
  },
  activeCharacter: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['toggle', 'add-initiative'])

const { fetchCampaignCharacters } = useCharacter()

// State
const charactersMap = ref({})
const sidebarWidth = ref(320)
const isResizing = ref(false)
const sessionOwnerId = ref(null) // [NEW]

// Sum/Calculator Mode State
const isSumming = ref(false)
const selectedMessageIds = ref(new Set())
const currentRollMode = ref('normal') // [NEW] Track roll mode

const toggleSumMode = () => {
  isSumming.value = !isSumming.value
  selectedMessageIds.value = new Set()
}

const clearSelection = () => {
  selectedMessageIds.value = new Set()
}

const toggleSelection = (msgId) => {
  const newSet = new Set(selectedMessageIds.value)
  if (newSet.has(msgId)) {
    newSet.delete(msgId)
  } else {
    newSet.add(msgId)
  }
  selectedMessageIds.value = newSet
}

const selectionTotal = computed(() => {
  let total = 0

  selectedMessageIds.value.forEach(id => {
    const msg = messages.value.find(m => m.id === id)
    if (msg) {
      try {
        const data = JSON.parse(msg.content)
        if (data && (typeof data.total === 'number' || data.total)) {
          total += parseInt(data.total)
        }
      } catch (e) {
        // Not JSON
      }
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
  // [NEW] Fetch Session Owner
  const { data: sessionData } = await supabase
    .from('sessions')
    .select('owner_id')
    .eq('id', props.campaignId)
    .single()

  if (sessionData) {
    sessionOwnerId.value = sessionData.owner_id
  }

  const { data: membersData } = await getMembers(props.campaignId)
  if (membersData) members.value = membersData

  // [NEW] Fetch Characters Map
  const chars = await fetchCampaignCharacters(props.campaignId)
  if (chars) {
    chars.forEach(c => {
      charactersMap.value[c.user_id] = c
    })
  }

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
    scrollToBottom()
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
  // 1. Determine Context
  const context = props.activeContext || props.activeCharacter || {}

  if (!formula.includes('@')) return formula

  return formula.replace(/@(\w+)/g, (match, key) => {
    const lowerKey = key.toLowerCase()

    // 2. Check Context for Stats
    if (context.stats) {
      // Check Modifiers
      if (lowerKey.endsWith('mod')) {
        const stat = lowerKey.replace('mod', '')
        const val = context.stats[stat]
        if (val !== undefined) return calculateModifier(val)
      }
      // Check Stats directly
      const val = context.stats[lowerKey]
      if (val !== undefined) return val
    }

    // 3. Check Top-level properties
    const topVal = context[lowerKey]
    if (topVal !== undefined) return topVal

    // 4. Default / Fallback
    console.warn(`Variable @${key} not found in context`, context)
    return '0' // Replace with 0 to prevent SyntaxError in DiceRoller
  })
}

// Helpers to resolve names
const getAuthorName = (userId) => {
  // 1. Check if DM (Owner)
  if (sessionOwnerId.value && userId === sessionOwnerId.value) {
    return 'Mestre'
  }

  // 2. Character Name
  if (charactersMap.value[userId]) {
    return charactersMap.value[userId].name
  }

  // 3. Fallbacks
  if (userId === props.currentUserId) {
    if (props.isOwner) return 'Mestre' // Redundant if sessionOwnerId matches, but safe
    if (props.activeCharacter) return props.activeCharacter.name
    return 'Você'
  }

  // 4. Member Email
  const member = members.value.find(m => m.user_id === userId)
  return member ? (member.email?.split('@')[0] || 'Desconhecido') : 'Desconhecido'
  // ... existing getAuthorName ...
  return member ? (member.email?.split('@')[0] || 'Desconhecido') : 'Desconhecido'
}

const getAuthorAvatar = (userId) => {
  // 1. Character Map (for everyone)
  if (charactersMap.value[userId]?.avatar_url) {
    return charactersMap.value[userId].avatar_url
  }

  // 2. Local Active Character (fallback or immediate update)
  if (userId === props.currentUserId && props.activeCharacter?.avatar_url) {
    return props.activeCharacter.avatar_url
  }

  // 3. DM Avatar? (Maybe future)
  if (sessionOwnerId.value && userId === sessionOwnerId.value) {
    // Return DM specific avatar if we had one, for now null lets it default to initial
    return null
  }

  return null
}


const handleSend = async () => {
  const content = newMessage.value.trim()
  if (!content || sending.value) return

  sending.value = true

  // Add to local history
  msgHistory.value.push(content)
  historyIndex.value = -1

  newMessage.value = ''

  try {
    // Check for commands
    if (content.startsWith('/r ') || content.startsWith('/roll ') || content.startsWith('/init ') || content.startsWith('/iniciativa ')) {
      let formula = content
        .replace(/^\/(r|roll)\s+/, '')
        .replace(/^\/(init|iniciativa)\s+/, '')

      // [NEW] Apply Roll Mode (Advantage/Disadvantage)
      if (currentRollMode.value !== 'normal') {
        const replacement = currentRollMode.value === 'advantage' ? '2d20kh1' : '2d20kl1'
        if (formula.includes('1d20')) {
          formula = formula.replace(/1d20/g, replacement)
        } else if (formula.includes('d20')) {
          formula = formula.replace(/(?<!\d)d20/g, replacement)
        }
      }

      // Determine context
      let context = 'generic'
      if (content.startsWith('/init') || content.startsWith('/iniciativa')) {
        context = 'initiative'
      }

      // Resolve Variables
      // Check for split syntax (Attack # Damage)
      let finalFormulaStr = formula
      if (formula.includes('#')) {
        const parts = formula.split('#')
        const attack = resolveVariables(parts[0].trim())
        const damage = resolveVariables(parts[1].trim())
        finalFormulaStr = `${attack} # ${damage}`
      } else {
        finalFormulaStr = resolveVariables(formula)
      }

      const rollResult = roll(finalFormulaStr, context === 'initiative' ? 'Iniciativa' : 'Rolagem', context)

      if (rollResult) {
        // Inject Author Name for Initiative Tracker
        if (props.activeContext && props.activeContext.name) {
          rollResult.name = props.activeContext.name
        } else {
          rollResult.name = getAuthorName(props.currentUserId)
        }

        // Preserve original formula (with @ variables)
        rollResult.originalFormula = content
          .replace(/^\/(r|roll)\s+/, '')
          .replace(/^\/(init|iniciativa)\s+/, '')

        if (rollResult.originalFormula.includes('#')) {
          rollResult.originalDamageFormula = rollResult.originalFormula.split('#')[1].trim()
        }

        console.log('Sending Roll Result (Standard):', rollResult)

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
    const prevMessages = [...messages.value]
    messages.value = messages.value.filter(m => m.id !== msgId)

    const result = await deleteMessage(msgId)
    if (!result.success) {
      messages.value = prevMessages
      alert('Falha ao excluir mensagem')
    }
  }
}

const handleRollDamage = async (payload) => {
  try {
    const formula = typeof payload === 'object' ? payload.formula : payload
    const overrideName = typeof payload === 'object' ? payload.name : null

    let finalFormula = resolveVariables(formula)

    const rollResult = roll(finalFormula, 'Dano', 'damage')
    if (rollResult) {
      // Preserve original formula
      rollResult.originalFormula = formula
      // 1. Set Name
      // Use override if present (from original attack), else use current author
      rollResult.name = overrideName || getAuthorName(props.currentUserId)

      // 2. Set Avatar
      // Try to find avatar for this name in characters map if we are overriding
      // (This helps when DM rolls damage for a character)
      if (overrideName) {
        const foundChar = Object.values(charactersMap.value).find(c => c.name === overrideName)
        if (foundChar && foundChar.avatar_url) {
          rollResult.avatar = foundChar.avatar_url
        }
      } else {
        // If we are just rolling ourselves, getAuthorAvatar might be used by ChatMessage based on ID, 
        // but we can also inject it to be explicit.
        const myAvatar = getAuthorAvatar(props.currentUserId)
        if (myAvatar) rollResult.avatar = myAvatar
      }

      console.log('Sending Roll Result (Damage):', rollResult)

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
      rollResult.originalFormula = formula
      rollResult.name = getAuthorName(props.currentUserId) // Inject name
      await sendMessage(props.campaignId, JSON.stringify(rollResult), selectedRecipient.value)
    }
  } catch (e) {
    console.error('Quick roll failed', e)
  }
}

const startResize = (e) => {
  isResizing.value = true
  document.addEventListener('mousemove', doResize)
  document.addEventListener('mouseup', stopResize)
  document.body.style.userSelect = 'none'
}

const doResize = (e) => {
  if (!isResizing.value) return
  const newWidth = window.innerWidth - e.clientX
  if (newWidth >= 280 && newWidth <= 350) {
    sidebarWidth.value = newWidth
  } else if (newWidth < 280) {
    sidebarWidth.value = 280
  } else if (newWidth > 350) {
    sidebarWidth.value = 350
  }
}

const stopResize = () => {
  isResizing.value = false
  document.removeEventListener('mousemove', doResize)
  document.removeEventListener('mouseup', stopResize)
  document.body.style.userSelect = ''
}
</script>

<template>
  <div class="fixed right-0 top-0 bottom-0 z-[100] flex flex-col transition-all duration-300 ease-out"
    :style="{ width: isOpen ? sidebarWidth + 'px' : '0px', transform: isOpen ? 'translateX(0)' : 'translateX(100%)' }">
    <!-- Resize Handle -->
    <div v-if="isOpen"
      class="absolute left-0 top-0 bottom-0 w-1 cursor-ew-resize hover:bg-lumina-detail/50 z-50 transition-colors"
      :class="{ 'bg-lumina-detail/50': isResizing }" @mousedown="startResize"></div>

    <!-- Main Sidebar Content -->
    <div v-show="isOpen" class="flex-1 flex flex-col bg-card border-l border-border shadow-2xl h-full w-full">

      <!-- Header -->
      <div class="h-14 shrink-0 border-b border-lumina-border flex items-center justify-between px-4 bg-card">
        <div class="flex items-center gap-2">
          <MessageSquare class="h-4 w-4 text-lumina-detail" />
          <span class="text-base font-bold text-lumina-text font-serif tracking-wide">Chat do Grupo</span>
        </div>
        <div
          class="text-[0.625rem] uppercase font-bold text-lumina-text-muted tracking-wider bg-lumina-bg px-2 py-1 rounded border border-lumina-border">
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
          <ChatMessage v-for="msg in messages" :key="msg.id" :message="msg" :senderName="getAuthorName(msg.user_id)"
            :avatarUrl="getAuthorAvatar(msg.user_id)" :currentUserId="currentUserId" :isOwner="isOwner"
            :is-capturing="isCapturing" :selectable="isSumming" :selected="selectedMessageIds.has(msg.id)"
            @delete="handleDelete" @roll-damage="handleRollDamage" @add-initiative="$emit('add-initiative', $event)"
            @toggle-select="toggleSelection" />
        </div>
      </div>

      <!-- Footer Area: Input & Recipient -->
      <div class="shrink-0 p-4 border-t border-lumina-border bg-card space-y-3 relative">

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
          <ChatDiceSelector :mode="currentRollMode" @update:mode="currentRollMode = $event" @roll="handleQuickRoll" />

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
          class="bg-lumina-card border border-lumina-border rounded-lg p-2 flex items-center justify-between z-50 animate-in fade-in slide-in-from-bottom-2">
          <div class="flex items-center gap-2 text-xs">
            <span class="text-lumina-text-muted uppercase tracking-wider">Selecionados: {{
              selectedMessageIds.size }}</span>
            <div class="h-4 w-px bg-lumina-border mx-2"></div>
            <span class="text-lumina-detail text-xs">TOTAL: {{ selectionTotal }}</span>
          </div>

          <div class="flex items-center gap-3">
            <div class="h-4 w-px bg-border"></div>
            <Button size="icon" class="h-6 w-6 hover:bg-muted text-muted-foreground hover:text-destructive"
              @click="clearSelection" title="Limpar Seleção">
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
/* Add any scoped styles if needed */
</style>
