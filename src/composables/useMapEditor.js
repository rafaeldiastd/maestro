import { ref, computed } from 'vue'

export function useMapEditor() {
    const canvas = ref(null)
    const ctx = ref(null)
    const backgroundImage = ref(null)

    // Camera state
    const camera = ref({
        x: 0,
        y: 0,
        zoom: 1.0,
        gridOffsetX: 0,
        gridOffsetY: 0,
        gridHeight: 50
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
        // Basic placeholder implementation for token drawing if no image logic provided
        // But the previous content had it. I'll include basic shape drawing.
        tokens.forEach(token => {
            if (token.layer === 'gm' && !showGMLayer) return

            const x = token.x
            const y = token.y
            const size = gridSize.value * (token.scale || 1.0)

            c.save()
            c.translate(x + size / 2, y + size / 2)

            c.fillStyle = '#f00'
            c.beginPath()
            c.arc(0, 0, size / 2, 0, Math.PI * 2)
            c.fill()

            c.restore()
        })
    }

    const drawCursors = (c, cursors) => {
        // Placeholder
    }

    const drawPings = (c, pings) => {
        // Placeholder
    }

    const drawDrawings = (c, drawings) => {
        // Placeholder
    }

    const drawCurrentDrawing = (c, path) => {
        // Placeholder
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
