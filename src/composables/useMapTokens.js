import { ref } from 'vue'

export function useMapTokens() {
    const tokens = ref([])

    const fetchTokens = async () => { }
    const createToken = async () => { }
    const updateToken = async () => { }
    const deleteToken = async () => { }
    const moveToken = async () => { }
    const subscribeToTokens = () => { return { unsubscribe: () => { } } }
    const refreshToken = async () => { }
    const setRole = () => { }

    return {
        tokens,
        fetchTokens,
        createToken,
        updateToken,
        deleteToken,
        moveToken,
        subscribeToTokens,
        refreshToken,
        setRole
    }
}
