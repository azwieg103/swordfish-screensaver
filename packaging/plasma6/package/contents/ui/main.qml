import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.zwiegnet.swordfish.geometry 1.0

WallpaperItem {
    id: root

    // Read live values from Plasma's KConfigPropertyMap. The cfg_* properties
    // belong to config.qml; they are not the runtime wallpaper settings.
    readonly property bool showClock: configuration.showClock
    readonly property bool showDate: configuration.showDate
    readonly property bool clock24Hour: configuration.clock24Hour
    readonly property string green: configuration.green
    readonly property int orbs: configuration.orbs
    readonly property int beamWidthSetting: configuration.beamWidth
    readonly property int speed: configuration.speed
    readonly property string shape: configuration.shape
    readonly property string direction: configuration.direction
    readonly property int glow: configuration.glow
    readonly property int orbBrightness: configuration.orbBrightness
    readonly property int orbitSize: configuration.orbitSize
    readonly property int trailLength: configuration.trailLength

    property rect screenRect: Qt.rect(0, 0, width, height)
    property rect desktopRect: Qt.rect(0, 0, width, height)
    property real screenX: screenRect.x - desktopRect.x
    property real screenY: screenRect.y - desktopRect.y
    property real desktopWidth: Math.max(1, desktopRect.width)
    property real desktopHeight: Math.max(1, desktopRect.height)
    property date currentDate: new Date()
    property string dateLabel: Qt.formatDate(currentDate, Qt.locale().dateFormat(Locale.LongFormat))
    property string timeLabel: Qt.formatTime(currentDate, root.clock24Hour ? "HH:mm:ss" : "h:mm:ss AP")

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
    property color plasmaColor: palette[root.green] || palette.classic

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
        timeLabel = Qt.formatTime(currentDate, root.clock24Hour ? "HH:mm:ss" : "h:mm:ss AP")
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            root.refreshDisplayGeometry()
            if (root.showClock || root.showDate)
                root.updateClock()
        }
    }

    // FrameAnimation is synchronized to Qt Quick's scene-graph frame delivery.
    // All wallpaper instances read the same monotonic clock from the native plugin.
    FrameAnimation {
        running: true
        onTriggered: shader.phase = DisplayGeometry.elapsedSeconds()
    }

    ShaderEffect {
        id: shader
        anchors.fill: parent
        property real phase: DisplayGeometry.elapsedSeconds()
        property vector2d desktopSize: Qt.vector2d(root.desktopWidth, root.desktopHeight)
        property vector2d screenOrigin: Qt.vector2d(root.screenX, root.screenY)
        property vector2d screenSize: Qt.vector2d(root.width, root.height)
        property color plasmaColor: root.plasmaColor
        property real orbitSize: root.orbitSize / 100.0
        property real beamWidth: root.beamWidthSetting
        property real glow: root.glow / 100.0
        property real orbBrightness: root.orbBrightness / 100.0
        property real orbCount: Math.max(1, Math.min(8, root.orbs))
        property real trailLength: root.trailLength
        property real speedScale: root.speed / 20.0
        property real shape: root.shape === "circle" ? 1.0 :
                             root.shape === "wide" ? 2.0 :
                             root.shape === "tall" ? 3.0 : 0.0
        property real direction: root.direction === "clockwise" ? 1.0 :
                                 root.direction === "counterclockwise" ? -1.0 : 0.0
        fragmentShader: "qrc:/org/zwiegnet/swordfish/shaders/swordfish.frag.qsb"
    }

    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 24
        visible: root.showClock || root.showDate

        Column {
            spacing: 2
            anchors.right: parent.right
            Text {
                visible: root.showDate
                text: root.dateLabel
                color: "white"
                font.pixelSize: 17
                style: Text.Outline
                styleColor: "#99000000"
            }
            Text {
                visible: root.showClock
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
