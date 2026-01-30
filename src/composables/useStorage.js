import { ref } from 'vue'
import { createStorage } from '@/lib/storage'

const currentProvider = ref(null)
const providerType = ref('supabase')
const providerConfig = ref({})

// Initialize from local storage or defaults
const initStorage = () => {
    const stored = JSON.parse(localStorage.getItem('lumina_storage_config') || '{}')

    // Default to Supabase if nothing stored, or if stored says supabase
    providerType.value = stored.type || 'supabase'
    providerConfig.value = stored.config || {}

    currentProvider.value = createStorage(providerType.value, providerConfig.value)
    console.log(`Storage initialized: ${providerType.value}`)
}

export function useStorage() {
    if (!currentProvider.value) {
        initStorage()
    }

    const setConfig = (type, config) => {
        providerType.value = type
        providerConfig.value = config

        // Persist
        localStorage.setItem('lumina_storage_config', JSON.stringify({
            type,
            config
        }))

        // Re-create provider
        currentProvider.value = createStorage(type, config)
    }

    return {
        storage: currentProvider,
        providerType,
        providerConfig,
        setConfig
    }
}
