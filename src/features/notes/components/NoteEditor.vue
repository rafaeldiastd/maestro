<script setup>
import { ref, watch, onBeforeUnmount } from 'vue'
import { watchDebounced } from '@vueuse/core'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Placeholder from '@tiptap/extension-placeholder'
import Image from '@tiptap/extension-image' // [NEW] Image support
import {
  Bold, Italic, Heading1, Heading2, List, ListOrdered, Quote, X, Image as ImageIcon, Minimize2, Maximize2, ArrowLeft, Tag
} from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

const props = defineProps({
  note: { type: Object, required: true }
})

const emit = defineEmits(['update', 'close', 'pick-image'])

const title = ref(props.note.title)
const localContent = ref(props.note.content)
const localTags = ref([...(props.note.tags || [])])
const newTagInput = ref('')

// --- Tags Logic ---
const addTag = () => {
  const val = newTagInput.value.trim()
  if (val && !localTags.value.includes(val)) {
    localTags.value.push(val)
  }
  newTagInput.value = ''
  save()
}

const removeTag = (index) => {
  localTags.value.splice(index, 1)
  save()
}

// --- Tiptap Setup ---
const editor = useEditor({
  content: props.note.content || '',
  extensions: [
    StarterKit,
    Image, // [NEW]
    Placeholder.configure({
      placeholder: 'Escreva algo incrível...',
    }),
  ],
  editorProps: {
    attributes: {
      class: 'prose prose-invert prose-sm sm:prose-base focus:outline-none max-w-none min-h-[500px] pb-20 px-2 editor-styles',
    },
  },
  onUpdate: ({ editor }) => {
    localContent.value = editor.getHTML()
  },
})

// Sync props -> editor
watch(() => props.note, (newNote) => {
  title.value = newNote.title
  localTags.value = [...(newNote.tags || [])]
  if (editor.value && newNote.content !== localContent.value) {
    editor.value.commands.setContent(newNote.content || '')
  }
})

// Auto-save
const save = () => {
  emit('update', {
    ...props.note,
    title: title.value,
    content: localContent.value,
    tags: localTags.value
  })
}

watchDebounced([title, localContent], save, { debounce: 1000 })

// Expose editor instance for parent to insert image
defineExpose({ editor })

onBeforeUnmount(() => {
  editor.value?.destroy()
})
</script>

<template>
  <div class="flex flex-col h-full bg-lumina-card text-lumina-text border-l border-lumina-border shadow-2xl relative">

    <!-- Header -->
    <div class="flex flex-col border-b border-lumina-border bg-lumina-bg/50">
      <div class="flex items-center justify-between p-4 pb-2">
        <input v-model="title"
          class="bg-transparent text-lg font-bold font-serif text-lumina-text placeholder-lumina-text-muted focus:outline-none w-full mr-4"
          placeholder="Nota Sem Título" />

        <div class="flex items-center gap-1">
          <Button variant="ghost" size="icon-sm" class="h-8 w-8 text-lumina-text-muted hover:text-lumina-text"
            @click="$emit('close')" title="Voltar para Lista">
            <ArrowLeft class="h-4 w-4" />
          </Button>
        </div>
      </div>

      <!-- Tags Input -->
      <div class="px-4 pb-3 flex items-center flex-wrap gap-2">
        <div v-for="(tag, index) in localTags" :key="index"
          class="flex items-center bg-lumina-detail/10 text-lumina-detail text-xs px-2 py-1 rounded-full border border-lumina-detail/20">
          <span>{{ tag }}</span>
          <button @click="removeTag(index)" class="ml-1 hover:text-lumina-text focus:outline-none">
            <X class="h-3 w-3" />
          </button>
        </div>

        <div class="relative flex items-center">
          <Tag class="h-3 w-3 absolute left-2 text-lumina-text-muted" />
          <input v-model="newTagInput" @keydown.enter.prevent="addTag"
            class="bg-lumina-bg/50 border border-lumina-border rounded-full py-1 pl-7 pr-3 text-xs text-lumina-text placeholder-lumina-text-muted focus:outline-none focus:border-lumina-detail w-32 focus:w-48 transition-all"
            placeholder="Nova tag..." />
        </div>
      </div>
    </div>

    <!-- Toolbar -->
    <div v-if="editor" class="flex flex-wrap items-center gap-1 p-2 border-b border-lumina-border bg-lumina-bg/30">
      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleBold().run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('bold'), 'text-lumina-text-muted': !editor.isActive('bold') }"
        class="h-8 w-8" title="Negrito">
        <Bold class="h-4 w-4" />
      </Button>
      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleItalic().run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('italic'), 'text-lumina-text-muted': !editor.isActive('italic') }"
        class="h-8 w-8" title="Itálico">
        <Italic class="h-4 w-4" />
      </Button>

      <div class="w-px h-4 bg-lumina-border mx-1"></div>

      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleHeading({ level: 1 }).run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('heading', { level: 1 }), 'text-lumina-text-muted': !editor.isActive('heading', { level: 1 }) }"
        class="h-8 w-8" title="Título 1">
        <Heading1 class="h-4 w-4" />
      </Button>
      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleHeading({ level: 2 }).run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('heading', { level: 2 }), 'text-lumina-text-muted': !editor.isActive('heading', { level: 2 }) }"
        class="h-8 w-8" title="Título 2">
        <Heading2 class="h-4 w-4" />
      </Button>

      <div class="w-px h-4 bg-lumina-border mx-1"></div>

      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleBulletList().run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('bulletList'), 'text-lumina-text-muted': !editor.isActive('bulletList') }"
        class="h-8 w-8" title="Lista com Marcadores">
        <List class="h-4 w-4" />
      </Button>
      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleOrderedList().run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('orderedList'), 'text-lumina-text-muted': !editor.isActive('orderedList') }"
        class="h-8 w-8" title="Lista Numerada">
        <ListOrdered class="h-4 w-4" />
      </Button>
      <Button size="icon-sm" variant="ghost" @click="editor.chain().focus().toggleBlockquote().run()"
        :class="{ 'bg-lumina-bg text-lumina-detail': editor.isActive('blockquote'), 'text-lumina-text-muted': !editor.isActive('blockquote') }"
        class="h-8 w-8" title="Citação">
        <Quote class="h-4 w-4" />
      </Button>

      <div class="w-px h-4 bg-lumina-border mx-1"></div>

      <!-- Image Button -->
      <Button size="icon-sm" variant="ghost" @click="$emit('pick-image')"
        class="h-8 w-8 text-lumina-text-muted hover:text-lumina-detail" title="Inserir Imagem">
        <ImageIcon class="h-4 w-4" />
      </Button>
    </div>

    <!-- Content -->
    <div class="flex-1 overflow-y-auto p-6 scrollbar-thin">
      <EditorContent :editor="editor" />
    </div>

  </div>
</template>

<style>
/* Tiptap Placeholder */
.ProseMirror p.is-editor-empty:first-child::before {
  color: #52525b;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

/* Custom Typography Styles for Editor */
.editor-styles h1 {
  @apply text-2xl font-bold font-serif text-lumina-detail mt-6 mb-4 pb-2 border-b border-lumina-border;
}

.editor-styles h2 {
  @apply text-xl font-bold text-lumina-text mt-5 mb-3;
}

.editor-styles blockquote {
  @apply border-l-4 border-lumina-detail pl-4 italic text-lumina-text-muted my-4;
}

.editor-styles ul {
  @apply list-disc list-outside ml-5 my-2;
}

.editor-styles ol {
  @apply list-decimal list-outside ml-5 my-2;
}

.editor-styles img {
  @apply rounded-lg shadow-md my-4 max-h-[400px] object-contain bg-black/20;
}
</style>
