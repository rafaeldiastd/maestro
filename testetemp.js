import { ref, computed } from 'vue'

export function useMapEditor() {
    const canvas = ref(null)
    const ctx = ref(null)
    const backgroundImage = ref(null)

    // Camera state
    const camera = ref({
        x: 0,
        y: 0,
        zoom: 1.0
    })

    // Grid settings
    const gridSize = ref(50)
    const gridColor = ref('#ffffff')
    const gridOpacity = ref(0.3)

    // Map dimensions
    const mapWidth = ref(4000)
    const mapHeight = ref(3000)

    // Mouse state
    const isDragging = ref(false)
    const dragStart = ref({ x: 0, y: 0 })
    const selectedToken = ref(null)

    // Initialize canvas
    const initCanvas = (canvasElement, settings = {}) => {
        canvas.value = canvasElement
        ctx.value = canvasElement.getContext('2d')

        if (settings.gridSize) gridSize.value = settings.gridSize
        if (settings.gridColor) gridColor.value = settings.gridColor
        if (settings.gridOpacity) gridOpacity.value = settings.gridOpacity
        if (settings.width) mapWidth.value = settings.width
        if (settings.height) mapHeight.value = settings.height

        // Set canvas size to window
        resizeCanvas()

        // Use ResizeObserver to detect container size changes (e.g. sidebar toggle)
        const resizeObserver = new ResizeObserver(() => {
            resizeCanvas()
        })
        resizeObserver.observe(canvasElement)

        // Store observer for cleanup
        canvasElement._resizeObserver = resizeObserver
    }

    const resizeCanvas = () => {
        if (!canvas.value) return
        canvas.value.width = canvas.value.offsetWidth
        canvas.value.height = canvas.value.offsetHeight
    }

    // Load background image
    const loadBackground = (url) => {
        return new Promise((resolve, reject) => {
            const img = new Image()
            img.crossOrigin = 'anonymous'
            img.onload = () => {
                backgroundImage.value = img
                resolve(img)
            }
            img.onerror = reject
            img.src = url
        })
    }

    // Convert screen coordinates to world coordinates
    const screenToWorld = (screenX, screenY) => {
        return {
            x: (screenX - camera.value.x) / camera.value.zoom,
            y: (screenY - camera.value.y) / camera.value.zoom
        }
    }

    // Convert world coordinates to screen coordinates
    const worldToScreen = (worldX, worldY) => {
        return {
            x: worldX * camera.value.zoom + camera.value.x,
            y: worldY * camera.value.zoom + camera.value.y
        }
    }

    // Snap to grid
    const snapToGrid = (x, y) => {
        const gridSizeScaled = gridSize.value
        return {
            x: Math.round(x / gridSizeScaled) * gridSizeScaled,
            y: Math.round(y / gridSizeScaled) * gridSizeScaled
        }
    }

    // Pan camera
    const panCamera = (deltaX, deltaY) => {
        camera.value.x += deltaX
        camera.value.y += deltaY
    }

    // Zoom camera
    const zoomCamera = (delta, centerX, centerY) => {
        const oldZoom = camera.value.zoom
        const zoomFactor = delta > 0 ? 1.1 : 0.9
        const newZoom = Math.max(0.1, Math.min(3, camera.value.zoom * zoomFactor))

        camera.value.zoom = newZoom

        // Zoom towards cursor position
        const zoomRatio = newZoom / oldZoom
        camera.value.x = centerX - (centerX - camera.value.x) * zoomRatio
        camera.value.y = centerY - (centerY - camera.value.y) * zoomRatio
    }

    // Render functions
    const render = (tokens = [], showGMLayer = true, cursors = new Map(), pings = [], drawings = [], currentDrawing = [], remoteDrags = new Map(), localDrag = null, currentUserId = null) => {
        if (!ctx.value || !canvas.value) return

        const c = ctx.value
        const w = canvas.value.width
        const h = canvas.value.height

        // Clear canvas
        c.clearRect(0, 0, w, h)

        // Save context
        c.save()

        // Apply camera transform
        c.translate(camera.value.x, camera.value.y)
        c.scale(camera.value.zoom, camera.value.zoom)

        // Draw background
        if (backgroundImage.value) {
            c.drawImage(backgroundImage.value, 0, 0, mapWidth.value, mapHeight.value)
        } else {
            // Draw default background
            c.fillStyle = '#1a1a1a'
            c.fillRect(0, 0, mapWidth.value, mapHeight.value)
        }

        // Draw grid
        drawGrid(c)

        // Draw tokens
        drawTokens(c, tokens, showGMLayer, remoteDrags, localDrag, currentUserId)

        // Draw drawings (top layer)
        drawDrawings(c, drawings)
        if (currentDrawing.length > 1) {
            drawCurrentDrawing(c, currentDrawing)
        }

        // Draw pings
        drawPings(c, pings)

        // Draw cursors
        drawCursors(c, cursors)

        // Restore context
        c.restore()
    }

    const drawGrid = (c) => {
        c.strokeStyle = gridColor.value
        c.globalAlpha = gridOpacity.value
        c.lineWidth = 1 / camera.value.zoom

        const offsetX = camera.value.gridOffsetX || 0
        const offsetY = camera.value.gridOffsetY || 0
        const cellHeight = camera.value.gridHeight || gridSize.value

        // Vertical lines (using gridSize for width)
        for (let x = offsetX; x <= mapWidth.value; x += gridSize.value) {
            c.beginPath()
            c.moveTo(x, 0)
            c.lineTo(x, mapHeight.value)
            c.stroke()
        }

        // Horizontal lines (using gridHeight for height)
        for (let y = offsetY; y <= mapHeight.value; y += cellHeight) {
            c.beginPath()
            c.moveTo(0, y)
            c.lineTo(mapWidth.value, y)
            c.stroke()
        }

        c.globalAlpha = 1.0
    }

    const drawTokens = (c, tokens, showGMLayer, remoteDrags, localDrag, currentUserId) => {
        tokens.forEach(token => {
            // Visibility logic:
            if (token.layer === 'gm' && !showGMLayer) return

            const x = token.x
            const y = token.y
            const size = gridSize.value * (token.scale || 1.0)
            const zoom = camera.value.zoom
            const isGMLayer = token.layer === 'gm'

            // Check if this token is being dragged
            let isDragging = false
            let dragColor = null
            let dragName = null

            const remoteDrag = remoteDrags?.get(token.id)
            if (remoteDrag) {
                isDragging = true
                dragColor = remoteDrag.color
                dragName = remoteDrag.name || 'User'
            }
            else if (localDrag?.tokenId === token.id) {
                isDragging = true
                dragColor = localDrag.color
                dragName = localDrag.name
            }

            c.save()
            c.translate(x + size / 2, y + size / 2)
            c.rotate((token.rotation || 0) * Math.PI / 180)

            if (isGMLayer) c.globalAlpha = 0.5

            if (isDragging) {
                c.shadowBlur = 15
                c.shadowColor = dragColor || '#ff0000'
            }

            // 2. Token Base (Circle)
            c.beginPath()
            c.arc(0, 0, size / 2, 0, Math.PI * 2)
            c.fillStyle = '#1e1e1e'
            c.fill()

            c.strokeStyle = isDragging ? (dragColor || '#ff0000') : (isGMLayer ? '#ff4444' : '#333')
            c.lineWidth = (isDragging ? 4 : 2) / zoom
            c.stroke()

            // 3. Avatar / Initials
            let avatarUrl = token.npc?.avatar_url || token.sheet?.avatar_url || token.sheet?.data?.avatar || token.sheet?.data?.bio?.avatar

            if (avatarUrl && token.image) {
                c.save()
                c.beginPath()
                c.arc(0, 0, size / 2 - 1, 0, Math.PI * 2)
                c.clip()
                c.drawImage(token.image, -size / 2, -size / 2, size, size)
                c.restore()
            } else {
                c.fillStyle = '#fff'
                c.font = `bold ${size / 3}px sans-serif`
                c.textAlign = 'center'
                c.textBaseline = 'middle'
                const name = token.npc?.name || token.sheet?.name || token.sheet?.data?.name || '?'
                const initials = name.substring(0, 2).toUpperCase()
                c.fillText(initials, 0, 0)
            }

            // 4. Stats Overlay
            const name = token.npc?.name || token.sheet?.name || token.sheet?.data?.name || ''

            // PERMISSION CHECK for HP: GM or Owner (using sheet.user_id)
            const isOwner = token.sheet?.user_id === currentUserId
            const canSeeHP = showGMLayer || isOwner
            const canSeeAC = showGMLayer // AC is always GM only

            const hp = (canSeeHP) ? (token.npc?.stats?.hp || token.sheet?.data?.stats?.hp?.value || token.sheet?.data?.hp?.value || '') : ''
            const ac = (canSeeAC) ? (token.npc?.stats?.ac || token.sheet?.data?.stats?.ac?.value || token.sheet?.data?.ac?.value || '') : ''

            if (name) {
                c.save()
                c.rotate(-(token.rotation || 0) * Math.PI / 180)
                c.fillStyle = 'white'
                c.strokeStyle = 'black'
                c.lineWidth = 2 / zoom
                c.font = `bold ${10 / zoom}px sans-serif`
                c.textAlign = 'center'
                c.strokeText(name, 0, size / 2 + (12 / zoom))
                c.fillText(name, 0, size / 2 + (12 / zoom))

                if (hp || ac) {
                    const statsText = `${hp ? 'HP:' + hp : ''} ${ac ? 'AC:' + ac : ''}`.trim()
                    if (statsText) {
                        c.font = `${8 / zoom}px sans-serif`
                        c.strokeText(statsText, 0, size / 2 + (22 / zoom))
                        c.fillText(statsText, 0, size / 2 + (22 / zoom))
                    }
                }
                c.restore()
            }

            // 5. Dragging Label
            if (isDragging && dragName) {
                c.save()
                c.rotate(-(token.rotation || 0) * Math.PI / 180)
                c.font = `bold ${12 / zoom}px sans-serif`
                const textMetrics = c.measureText(dragName)
                const padding = 6 / zoom
                const textWidth = textMetrics.width
                const height = 20 / zoom
                const radius = 6 / zoom
                const pillX = -textWidth / 2 - padding
                const pillY = -size / 2 - height - (10 / zoom)
                c.fillStyle = dragColor || '#ff0000'
                c.beginPath()
                c.roundRect(pillX, pillY, textWidth + (padding * 2), height, radius)
                c.fill()
                c.fillStyle = 'white'
                c.textAlign = 'left'
                c.textBaseline = 'middle'
                c.fillText(dragName, pillX + padding, pillY + (height / 2))
                c.restore()
            }

            if (selectedToken.value?.id === token.id && !isDragging) {
                c.strokeStyle = '#ffd700'
                c.lineWidth = 3 / zoom
                c.beginPath()
                c.arc(0, 0, size / 2 + 2, 0, Math.PI * 2)
                c.stroke()
            }
            c.restore()
        })
    }

    const drawCursors = (c, cursors) => {
        cursors.forEach(cursor => {
            if (!cursor.x || !cursor.y) return

            c.save()
            c.translate(cursor.x, cursor.y)

            const zoom = camera.value.zoom
            const color = cursor.color || '#ff0000'
            const name = cursor.characterName || 'User'

            // 1. Draw "Ball" (Cursor Point)
            c.shadowColor = 'rgba(0, 0, 0, 0.5)'
            c.shadowBlur = 4
            c.fillStyle = color
            c.beginPath()
            c.arc(0, 0, 6 / zoom, 0, Math.PI * 2)
            c.fill()

            // Reset shadow for text pill
            c.shadowColor = 'transparent'
            c.shadowBlur = 0

            // 2. Draw "Pill" (Name Tag)
            c.font = `bold ${12 / zoom}px sans-serif`
            const textMetrics = c.measureText(name)
            const padding = 6 / zoom
            const textWidth = textMetrics.width
            const height = 20 / zoom
            const radius = 6 / zoom

            // Position pill to the right of the ball
            const pillX = 10 / zoom
            const pillY = -height / 2

            // Draw Pill Background
            c.fillStyle = color
            c.beginPath()
            c.roundRect(pillX, pillY, textWidth + (padding * 2), height, radius)
            c.fill()

            // Draw Text
            c.fillStyle = 'white'
            c.textBaseline = 'middle'
            c.fillText(name, pillX + padding, pillY + (height / 2))

            c.restore()
        })
    }

    const drawPings = (c, pings) => {
        pings.forEach(ping => {
            c.save()
            c.translate(ping.x, ping.y)

            // Cor branca para todos os pings
            c.strokeStyle = '#ffffff'
            c.lineWidth = 3 / camera.value.zoom  // Linha mais grossa

            // Animated circles - MAIOR (80px ao invés de 50px)
            const time = Date.now() / 500
            const scale = (time % 1) * 80  // Aumentado de 50 para 80

            // Círculo externo com fade out
            c.globalAlpha = 1 - (time % 1)
            c.beginPath()
            c.arc(0, 0, scale, 0, Math.PI * 2)
            c.stroke()

            // Círculo intermediário com fade out
            c.globalAlpha = 1 - ((time % 1) * 0.7)
            c.beginPath()
            c.arc(0, 0, scale / 2, 0, Math.PI * 2)
            c.stroke()

            // Ponto central (sempre visível)
            c.globalAlpha = 1
            c.fillStyle = '#ffffff'
            c.beginPath()
            c.arc(0, 0, 8 / camera.value.zoom, 0, Math.PI * 2)
            c.fill()

            // Nome do personagem com outline
            c.fillStyle = '#ffffff'
            c.strokeStyle = '#000000'
            c.lineWidth = 3 / camera.value.zoom
            c.font = `bold ${16 / camera.value.zoom}px sans-serif`  // Fonte maior
            c.textAlign = 'center'
            const name = ping.character_name || 'Ping'
            c.strokeText(name, 0, -scale - 10)
            c.fillText(name, 0, -scale - 10)

            c.restore()
        })
    }

    const drawDrawings = (c, drawings) => {
        drawings.forEach(drawing => {
            const path = typeof drawing.path === 'string' ? JSON.parse(drawing.path) : drawing.path
            if (!path || path.length < 2) return

            c.strokeStyle = drawing.color
            c.lineWidth = drawing.brush_size / camera.value.zoom
            c.lineCap = 'round'
            c.lineJoin = 'round'

            c.beginPath()
            c.moveTo(path[0].x, path[0].y)

            for (let i = 1; i < path.length; i++) {
                c.lineTo(path[i].x, path[i].y)
            }

            c.stroke()
        })
    }

    const drawCurrentDrawing = (c, path) => {
        if (path.length < 2) return

        c.strokeStyle = '#ff0000' // Current drawing color logic handled in component
        c.lineWidth = 4 / camera.value.zoom
        c.lineCap = 'round'
        c.lineJoin = 'round'

        c.beginPath()
        c.moveTo(path[0].x, path[0].y)

        for (let i = 1; i < path.length; i++) {
            c.lineTo(path[i].x, path[i].y)
        }

        c.stroke()
    }

    // Cleanup
    const cleanup = () => {
        if (canvas.value && canvas.value._resizeObserver) {
            canvas.value._resizeObserver.disconnect()
        }
        window.removeEventListener('resize', resizeCanvas)
    }

    return {
        canvas,
        ctx,
        camera,
        gridSize,
        gridColor,
        gridOpacity,
        mapWidth,
        mapHeight,
        isDragging,
        dragStart,
        selectedToken,
        backgroundImage,
        initCanvas,
        loadBackground,
        screenToWorld,
        worldToScreen,
        snapToGrid,
        panCamera,
        zoomCamera,
        render,
        cleanup
    }
}
