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
    property int cfg_beamWidth: 14
    property int cfg_speed: 10
    property string cfg_shape: "oval"
    property string cfg_direction: "clockwise"
    property int cfg_glow: 70
    property int cfg_orbitSize: 100

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
        "teal": Qt.rgba(0.02, 0.92, 0.72, 1),
        "ice": Qt.rgba(0.18, 0.88, 1.0, 1),
        "amber": Qt.rgba(1.0, 0.58, 0.08, 1),
        "violet": Qt.rgba(0.72, 0.35, 1.0, 1),
        "white": Qt.rgba(0.88, 1.0, 1.0, 1)
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
            // One wide oval spans the virtual desktop and crosses all displays.
            const scale = root.cfg_orbitSize / 100.0
            let rx = virtualWidth * 0.43 * scale
            let ry = virtualHeight * 0.36 * scale
            if (root.cfg_shape === "circle") {
                rx = Math.min(virtualWidth, virtualHeight) * 0.40 * scale
                ry = rx
            } else if (root.cfg_shape === "wide") {
                ry *= 0.62
            } else if (root.cfg_shape === "tall") {
                rx *= 0.62
            }
            const t = root.phase * root.cfg_speed / 10.0
            const direction = root.cfg_direction === "counterclockwise" ? -1 : 1
            const angle = direction * t * Math.PI * 2 / 18.0
            const pulse = 0.5 + 0.5 * Math.sin(t * Math.PI * 2 / 3.2)
            const glow = root.plasmaColor
            const greens = [glow, glow, glow, glow]

            ctx.reset()
            ctx.fillStyle = "#010207"
            ctx.fillRect(0, 0, w, h)
            ctx.save()

            // Draw in virtual-desktop coordinates so the single orbit is continuous
            // across all four monitors, including mixed/negative screen origins.
            ctx.translate(-root.screenX, -root.screenY)
            ctx.translate(cx, cy)

            // Draw one continuous, non-fading oval. Its brightness rises smoothly
            // around each moving orb, so the two heads visually illuminate the track.
            const orbCount = Math.max(1, Math.min(8, root.cfg_orbs))
            const orbAngles = []
            for (let i = 0; i < orbCount; ++i)
                orbAngles.push(angle + i * Math.PI * 2 / orbCount)
            const segments = 240
            for (let j = 0; j < segments; ++j) {
                const a1 = j / segments * Math.PI * 2
                const a2 = (j + 1) / segments * Math.PI * 2
                const mid = (a1 + a2) / 2
                let energy = 0
                for (let i = 0; i < orbAngles.length; ++i) {
                    let delta = Math.abs(mid - orbAngles[i]) % (Math.PI * 2)
                    if (delta > Math.PI) delta = Math.PI * 2 - delta
                    energy = Math.max(energy, Math.exp(-(delta * delta) / (2 * 0.48 * 0.48)))
                }
                const brightness = 0.18 + energy * (0.82 + pulse * 0.18) * root.cfg_glow / 100.0
                const green = greens[0]
                ctx.beginPath()
                ctx.moveTo(rx * Math.cos(a1), ry * Math.sin(a1))
                ctx.lineTo(rx * Math.cos(a2), ry * Math.sin(a2))
                ctx.strokeStyle = Qt.rgba(
                    Math.min(1, green.r * brightness),
                    Math.min(1, green.g * brightness),
                    Math.min(1, green.b * brightness), 1)
                ctx.lineWidth = 0.7 + root.cfg_beamWidth / 10.0
                ctx.lineCap = "round"
                ctx.stroke()
            }

            // Two compact plasma heads move in the same direction, spaced half an orbit apart. The oval
            // remains connected and visible behind them; only its brightness changes.
            for (let i = 0; i < orbAngles.length; ++i) {
                const a = orbAngles[i]
                const x = rx * Math.cos(a)
                const y = ry * Math.sin(a)
                const color = glow
                const orbPulse = 0.82 + 0.18 * Math.sin(t * 2.0 + i * 2.4)
                const headRadius = (3.0 + root.cfg_beamWidth * 0.22) * orbPulse
                const halo = ctx.createRadialGradient(x, y, 1, x, y, headRadius * 2.8)
                halo.addColorStop(0, "#ffffff")
                halo.addColorStop(0.24, color)
                halo.addColorStop(0.62, Qt.rgba(color.r, color.g, color.b, 0.38))
                halo.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0))
                ctx.fillStyle = halo
                ctx.beginPath()
                ctx.arc(x, y, headRadius * 2.8, 0, Math.PI * 2)
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
