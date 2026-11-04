import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.zwiegnet.swordfish.geometry 1.0

WallpaperItem {
    id: root

    property bool cfg_showClock: false
    property bool cfg_showDate: false
    property bool cfg_clock24Hour: true
    property string cfg_green: "classic"
    property int cfg_orbs: 1
    property int cfg_beamWidth: 14
    property int cfg_speed: 20
    property string cfg_shape: "oval"
    property string cfg_direction: "clockwise"
    property int cfg_glow: 70
    property int cfg_orbitSize: 100

    property rect screenRect: Qt.rect(0, 0, width, height)
    property rect desktopRect: Qt.rect(0, 0, width, height)
    property real screenX: screenRect.x - desktopRect.x
    property real screenY: screenRect.y - desktopRect.y
    property real desktopWidth: Math.max(1, desktopRect.width)
    property real desktopHeight: Math.max(1, desktopRect.height)
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

    function refreshDisplayGeometry() {
        const nextScreen = DisplayGeometry.screenGeometry(root)
        const nextDesktop = DisplayGeometry.virtualGeometry(root)
        if (nextScreen.width > 0 && nextScreen.height > 0)
            screenRect = nextScreen
        if (nextDesktop.width > 0 && nextDesktop.height > 0)
            desktopRect = nextDesktop
    }

    function updateClock() {
        currentDate = new Date()
        dateLabel = Qt.formatDate(currentDate, Qt.locale().dateFormat(Locale.LongFormat))
        timeLabel = Qt.formatTime(currentDate, cfg_clock24Hour ? "HH:mm:ss" : "h:mm:ss AP")
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            root.refreshDisplayGeometry()
            if (root.cfg_showClock || root.cfg_showDate)
                root.updateClock()
        }
    }

    // FrameAnimation is synchronized to Qt Quick's scene-graph frame delivery.
    // All wallpaper instances read the same monotonic clock from the native plugin.
    FrameAnimation {
        running: true
        onTriggered: shader.phase = DisplayGeometry.elapsedSeconds() * root.cfg_speed / 10.0
    }

    ShaderEffect {
        id: shader
        anchors.fill: parent
        property real phase: DisplayGeometry.elapsedSeconds() * root.cfg_speed / 10.0
        property vector2d desktopSize: Qt.vector2d(root.desktopWidth, root.desktopHeight)
        property vector2d screenOrigin: Qt.vector2d(root.screenX, root.screenY)
        property vector2d screenSize: Qt.vector2d(root.width, root.height)
        property color plasmaColor: root.plasmaColor
        property real orbitSize: root.cfg_orbitSize / 100.0
        property real beamWidth: root.cfg_beamWidth
        property real glow: root.cfg_glow / 100.0
        property real orbCount: Math.max(1, Math.min(8, root.cfg_orbs))
        property real shape: root.cfg_shape === "circle" ? 1.0 :
                             root.cfg_shape === "wide" ? 2.0 :
                             root.cfg_shape === "tall" ? 3.0 : 0.0
        property real direction: root.cfg_direction === "counterclockwise" ? -1.0 : 1.0
        fragmentShader: "qrc:/org/zwiegnet/swordfish/shaders/swordfish.frag.qsb"
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
