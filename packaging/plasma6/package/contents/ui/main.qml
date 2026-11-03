import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.zwiegnet.swordfish.geometry 1.0

WallpaperItem {
    id: root

    property bool cfg_showClock: true
    property bool cfg_showDate: true
    property bool cfg_clock24Hour: true
    property string cfg_green: "classic"
    property int cfg_orbs: 3
    property int cfg_beamWidth: 25

    // Read geometry from QScreen, not QML's per-screen Screen attached object.
    // virtualGeometry is the bounding rectangle of all connected displays.
    property rect screenRect: Qt.rect(0, 0, width, height)
    property rect desktopRect: Qt.rect(0, 0, width, height)
    property real screenX: screenRect.x - desktopRect.x
    property real screenY: screenRect.y - desktopRect.y
    property real desktopWidth: Math.max(1, desktopRect.width)
    property real desktopHeight: Math.max(1, desktopRect.height)

    function refreshDisplayGeometry() {
        const nextScreen = DisplayGeometry.screenGeometry(root)
        const nextDesktop = DisplayGeometry.virtualGeometry(root)
        if (nextScreen.width > 0 && nextScreen.height > 0)
            screenRect = nextScreen
        if (nextDesktop.width > 0 && nextDesktop.height > 0)
            desktopRect = nextDesktop
        canvas.requestPaint()
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.refreshDisplayGeometry()
    }

    property real phase: (Date.now() / 1000.0) % 16000000
    property date currentDate: new Date()
    property string dateLabel: Qt.formatDate(currentDate, Qt.locale().dateFormat(Locale.LongFormat))
    property string timeLabel: Qt.formatTime(currentDate, cfg_clock24Hour ? "HH:mm:ss" : "h:mm:ss AP")
    property var palette: ({
        "classic": Qt.rgba(0.28, 1.0, 0.035, 1),
        "lime": Qt.rgba(0.62, 1.0, 0.015, 1),
        "emerald": Qt.rgba(0.02, 0.88, 0.34, 1),
        "teal": Qt.rgba(0.02, 0.92, 0.72, 1)
    })
    property color plasmaColor: palette[cfg_green] || palette.classic

    Timer {
        interval: 33
        repeat: true
        running: true
        onTriggered: {
            root.phase = (Date.now() / 1000.0) % 16000000
            canvas.requestPaint()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.updateClock()
    }

    function updateClock() {
        currentDate = new Date()
        dateLabel = Qt.formatDate(currentDate, Qt.locale().dateFormat(Locale.LongFormat))
        timeLabel = Qt.formatTime(currentDate, cfg_clock24Hour ? "HH:mm:ss" : "h:mm:ss AP")
    }

    Component.onCompleted: { updateClock(); refreshDisplayGeometry() }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            const ctx = getContext("2d")
            const w = width
            const h = height
            const virtualWidth = root.desktopWidth
            const virtualHeight = root.desktopHeight
            const cx = virtualWidth / 2
            const cy = virtualHeight / 2
            // One circular orbit spans the virtual desktop and crosses all displays.
            const orbitRadius = Math.min(virtualWidth, virtualHeight) * 0.43
            const rx = orbitRadius
            const ry = orbitRadius
            const t = root.phase
            const rev = (t % 50) < 25 ? 1 : -1
            const within = (t % 25) / 25
            const angle = rev > 0 ? within * Math.PI * 2 : (1 - within) * Math.PI * 2
            const pulse = 0.5 + 0.5 * Math.sin(t * Math.PI * 2 / 3.2)
            const glow = root.plasmaColor
            const greens = [
                Qt.rgba(0.22, 1.0, 0.025, 1),
                Qt.rgba(0.02, 0.95, 0.28, 1),
                Qt.rgba(0.42, 1.0, 0.08, 1),
                Qt.rgba(0.02, 0.78, 0.48, 1)
            ]

            ctx.reset()
            ctx.fillStyle = "#010207"
            ctx.fillRect(0, 0, w, h)
            ctx.save()

            // Draw in virtual-desktop coordinates so the single orbit is continuous
            // across all four monitors, including mixed/negative screen origins.
            ctx.translate(-root.screenX, -root.screenY)
            ctx.translate(cx, cy)

            // A single thick ring with a soft, breathing green halo.
            for (let layer = 3; layer >= 1; --layer) {
                ctx.beginPath()
                ctx.arc(0, 0, orbitRadius, 0, Math.PI * 2)
                ctx.strokeStyle = Qt.rgba(glow.r, glow.g, glow.b,
                                          (0.035 + pulse * 0.025) / layer)
                ctx.lineWidth = root.cfg_beamWidth * (1.8 + layer * 1.25) * (0.9 + pulse * 0.12)
                ctx.stroke()
            }
            ctx.beginPath()
            ctx.arc(0, 0, orbitRadius, 0, Math.PI * 2)
            const ringGradient = ctx.createLinearGradient(-orbitRadius, -orbitRadius,
                                                            orbitRadius, orbitRadius)
            ringGradient.addColorStop(0, "#18e85b")
            ringGradient.addColorStop(0.32, "#a5ff42")
            ringGradient.addColorStop(0.62, "#00d878")
            ringGradient.addColorStop(1, "#55ff18")
            ctx.strokeStyle = ringGradient
            ctx.lineWidth = root.cfg_beamWidth * (0.62 + pulse * 0.12)
            ctx.stroke()

            // One bright comet travels around the ring, reversing direction periodically.
            const x = orbitRadius * Math.cos(angle)
            const y = orbitRadius * Math.sin(angle)
            const tail = ctx.createLinearGradient(
                orbitRadius * Math.cos(angle - rev * 0.9),
                orbitRadius * Math.sin(angle - rev * 0.9), x, y)
            tail.addColorStop(0, Qt.rgba(0.05, 1.0, 0.25, 0))
            tail.addColorStop(0.72, Qt.rgba(0.25, 1.0, 0.12, 0.7))
            tail.addColorStop(1, "#efffed")
            ctx.beginPath()
            for (let j = 0; j <= 40; ++j) {
                const u = j / 40
                const trailAngle = angle - rev * 0.9 * (1 - u)
                const px = orbitRadius * Math.cos(trailAngle)
                const py = orbitRadius * Math.sin(trailAngle)
                if (j === 0) ctx.moveTo(px, py)
                else ctx.lineTo(px, py)
            }
            ctx.strokeStyle = tail
            ctx.lineWidth = root.cfg_beamWidth * (0.9 + pulse * 0.2)
            ctx.lineCap = "round"
            ctx.stroke()

            const headRadius = root.cfg_beamWidth * (1.8 + pulse * 0.45)
            const head = ctx.createRadialGradient(x, y, 1, x, y, headRadius)
            head.addColorStop(0, "#ffffff")
            head.addColorStop(0.25, "#d8ffd0")
            head.addColorStop(1, Qt.rgba(0.05, 1.0, 0.25, 0))
            ctx.fillStyle = head
            ctx.beginPath()
            ctx.arc(x, y, headRadius, 0, Math.PI * 2)
            ctx.fill()

            // Multiple plasma orbs follow the same continuous circular path.
            for (let i = 0; i < root.cfg_orbs; ++i) {
                const orbAngle = angle + Math.PI * 2 * i / Math.max(1, root.cfg_orbs)
                const ox = orbitRadius * Math.cos(orbAngle)
                const oy = orbitRadius * Math.sin(orbAngle)
                const orbPulse = 0.65 + 0.35 * Math.sin(t * 2.1 + i * 1.7)
                const radius = (7 + 2 * (i % 3)) * orbPulse
                const orb = ctx.createRadialGradient(ox, oy, 1, ox, oy, radius * 3.8)
                const color = greens[i % greens.length]
                orb.addColorStop(0, "#ffffff")
                orb.addColorStop(0.2, color)
                orb.addColorStop(0.58, Qt.rgba(color.r, color.g, color.b, 0.35))
                orb.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0))
                ctx.fillStyle = orb
                ctx.beginPath()
                ctx.arc(ox, oy, radius * 3.8, 0, Math.PI * 2)
                ctx.fill()
            }
            ctx.restore()
        }
    }

    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 24
        visible: root.cfg_showClock || root.cfg_showDate

        Column {
            spacing: 2
            anchors.right: parent.right
            Text {
                visible: root.cfg_showDate
                text: root.dateLabel
                color: "white"
                font.pixelSize: 17
                style: Text.Outline
                styleColor: "#99000000"
            }
            Text {
                visible: root.cfg_showClock
                text: root.timeLabel
                color: "white"
                font.pixelSize: 28
                font.bold: true
                style: Text.Outline
                styleColor: "#99000000"
            }
        }
    }
}
