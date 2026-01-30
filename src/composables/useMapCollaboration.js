import { ref } from 'vue'

export function useMapCollaboration() {
    const cursors = ref(new Map())
    const pings = ref([])
    const drawings = ref([])

    const initCollaboration = async () => { }
    const updateCursor = () => { }
    const createPing = async () => { }
    const createDrawing = async () => { }
    const clearDrawings = async () => { }
    const broadcastTokenMove = () => { }
    const broadcastTokenDrop = () => { }
    const broadcastTokenVisibility = () => { }
    const updatePresence = () => { }

    return {
        cursors,
        pings,
        drawings,
        initCollaboration,
        updateCursor,
        createPing,
        createDrawing,
        clearDrawings,
        broadcastTokenMove,
        broadcastTokenDrop,
        broadcastTokenVisibility,
        updatePresence,
        instanceId: 'stub'
    }
}
