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
            const rx = virtualWidth * 0.43
            const ry = virtualHeight * 0.43
            const t = root.phase
            const rev = (t % 50) < 25 ? 1 : -1
            const within = (t % 25) / 5
            const angle = rev > 0 ? within * Math.PI * 2 : (5 - within) * Math.PI * 2
            const split = t % 32
            const splitWave = (split < 8 || split >= 24) ? 0 :
                (split < 12 ? (split - 8) / 4 :
                 split < 20 ? 1 : (24 - split) / 4)
            const beams = splitWave < 0.34 ? 1 : (splitWave < 0.84 ? 2 : 4)
            const glow = root.plasmaColor

            ctx.reset()
            ctx.fillStyle = "#010207"
            ctx.fillRect(0, 0, w, h)
            ctx.save()

            // Draw in virtual-desktop coordinates, offset to this screen's
            // origin. QScreen geometry handles negative and mixed coordinates.
            ctx.translate(-root.screenX, -root.screenY)
            ctx.translate(cx, cy)

            // Dim circular plasma orbit and its luminous outer halo.
            for (let layer = 3; layer >= 0; --layer) {
                ctx.beginPath()
                ctx.ellipse(0, 0, rx, ry, 0, 0, Math.PI * 2)
                ctx.strokeStyle = Qt.rgba(glow.r, glow.g, glow.b, 0.025 + layer * 0.018)
                ctx.lineWidth = root.cfg_beamWidth * (0.75 + layer * 0.55)
                ctx.stroke()
            }
            ctx.beginPath()
            ctx.ellipse(0, 0, rx, ry, 0, 0, Math.PI * 2)
            ctx.strokeStyle = "#baffc7"
            ctx.lineWidth = 1.5
            ctx.stroke()

            // Beam heads share the same epoch-based phase on every monitor.
            for (let b = 0; b < beams; ++b) {
                const a = angle + (Math.PI * 2 * b / beams)
                const x = rx * Math.cos(a)
                const y = ry * Math.sin(a)
                const tail = ctx.createLinearGradient(
                    x - Math.cos(a) * rx * 0.42, y - Math.sin(a) * ry * 0.42, x, y)
                tail.addColorStop(0, Qt.rgba(glow.r, glow.g, glow.b, 0))
                tail.addColorStop(0.72, Qt.rgba(glow.r, glow.g, glow.b, 0.18))
                tail.addColorStop(1, "#e7ffed")
                ctx.beginPath()
                for (let j = 0; j <= 32; ++j) {
                    const u = j / 32
                    const trailAngle = a - rev * 1.05 * (1 - u)
                    const px = rx * Math.cos(trailAngle)
                    const py = ry * Math.sin(trailAngle)
                    if (j === 0) ctx.moveTo(px, py)
                    else ctx.lineTo(px, py)
                }
                ctx.strokeStyle = tail
                ctx.lineWidth = root.cfg_beamWidth
                ctx.lineCap = "round"
                ctx.stroke()
                const head = ctx.createRadialGradient(x, y, 1, x, y, root.cfg_beamWidth * 2.8)
                head.addColorStop(0, "#ffffff")
                head.addColorStop(0.2, "#c9ffd2")
                head.addColorStop(1, Qt.rgba(glow.r, glow.g, glow.b, 0))
                ctx.fillStyle = head
                ctx.beginPath()
                ctx.arc(x, y, root.cfg_beamWidth * 2.8, 0, Math.PI * 2)
                ctx.fill()
            }

            // Small orbiting plasma balls.
            for (let i = 0; i < root.cfg_orbs; ++i) {
                const a = angle + Math.PI * 2 * i / root.cfg_orbs
                const x = rx * 0.72 * Math.cos(a)
                const y = ry * 0.72 * Math.sin(a)
                const radius = 7 + 3 * (i % 3)
                const orb = ctx.createRadialGradient(x, y, 1, x, y, radius * 4)
                orb.addColorStop(0, "#ffffff")
                orb.addColorStop(0.22, glow)
                orb.addColorStop(1, Qt.rgba(glow.r, glow.g, glow.b, 0))
                ctx.fillStyle = orb
                ctx.beginPath()
                ctx.arc(x, y, radius * 4, 0, Math.PI * 2)
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
