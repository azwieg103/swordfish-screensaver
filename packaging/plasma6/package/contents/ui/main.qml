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
    property int cfg_speed: 10

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
            // One wide oval spans the virtual desktop and crosses all displays.
            const rx = virtualWidth * 0.43
            const ry = virtualHeight * 0.36
            const t = root.phase * root.cfg_speed / 10.0
            const angle = t * Math.PI * 2 / 18.0
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

            // Thick oval track with a soft, breathing green halo.
            for (let layer = 3; layer >= 1; --layer) {
                ctx.beginPath()
                ctx.ellipse(0, 0, rx, ry, 0, 0, Math.PI * 2)
                ctx.strokeStyle = Qt.rgba(glow.r, glow.g, glow.b,
                                          (0.035 + pulse * 0.025) / layer)
                ctx.lineWidth = root.cfg_beamWidth * (1.8 + layer * 1.25) * (0.9 + pulse * 0.12)
                ctx.stroke()
            }
            ctx.beginPath()
            ctx.ellipse(0, 0, rx, ry, 0, 0, Math.PI * 2)
            const ringGradient = ctx.createLinearGradient(-rx, -ry, rx, ry)
            ringGradient.addColorStop(0, "#18e85b")
            ringGradient.addColorStop(0.32, "#a5ff42")
            ringGradient.addColorStop(0.62, "#00d878")
            ringGradient.addColorStop(1, "#55ff18")
            ctx.strokeStyle = ringGradient
            ctx.lineWidth = root.cfg_beamWidth * (0.62 + pulse * 0.12)
            ctx.stroke()

            // Exactly two glowing comet-orbs travel in opposite directions.
            for (let i = 0; i < 2; ++i) {
                const direction = i === 0 ? 1 : -1
                const a = angle * direction + (i === 1 ? Math.PI : 0)
                const x = rx * Math.cos(a)
                const y = ry * Math.sin(a)
                const tailAngle = 0.95
                const color = greens[i]
                const tail = ctx.createLinearGradient(
                    rx * Math.cos(a - direction * tailAngle),
                    ry * Math.sin(a - direction * tailAngle), x, y)
                tail.addColorStop(0, Qt.rgba(color.r, color.g, color.b, 0))
                tail.addColorStop(0.68, Qt.rgba(color.r, color.g, color.b, 0.72))
                tail.addColorStop(1, "#f4fff0")
                ctx.beginPath()
                for (let j = 0; j <= 36; ++j) {
                    const u = j / 36
                    const trailA = a - direction * tailAngle * (1 - u)
                    const px = rx * Math.cos(trailA)
                    const py = ry * Math.sin(trailA)
                    if (j === 0) ctx.moveTo(px, py)
                    else ctx.lineTo(px, py)
                }
                ctx.strokeStyle = tail
                ctx.lineWidth = root.cfg_beamWidth * (0.95 + pulse * 0.25)
                ctx.lineCap = "round"
                ctx.stroke()

                const orbPulse = 0.7 + 0.3 * Math.sin(t * 2.0 + i * 2.4)
                const headRadius = root.cfg_beamWidth * (1.7 + pulse * 0.4) * orbPulse
                const head = ctx.createRadialGradient(x, y, 1, x, y, headRadius)
                head.addColorStop(0, "#ffffff")
                head.addColorStop(0.24, color)
                head.addColorStop(1, Qt.rgba(color.r, color.g, color.b, 0))
                ctx.fillStyle = head
                ctx.beginPath()
                ctx.arc(x, y, headRadius, 0, Math.PI * 2)
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
