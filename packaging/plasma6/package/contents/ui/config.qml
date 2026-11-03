import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    // KDE Plasma 6 Screen Locker injects these properties when opening
    // the wallpaper configuration page.
    property var configDialog
    property var wallpaperConfiguration

    property alias cfg_showClock: showClock.checked
    property alias cfg_showDate: showDate.checked
    property alias cfg_clock24Hour: clock24Hour.checked
    property alias cfg_green: green.currentValue
    property alias cfg_beamWidth: beamWidth.value
    property alias cfg_speed: speed.value

    Kirigami.FormLayout {
            anchors.fill: parent
        Controls.CheckBox {
            id: showClock
            Kirigami.FormData.label: i18n("Clock")
            text: i18n("Show time")
    }
    Controls.CheckBox {
        id: showDate
        text: i18n("Show date above time")
    }
    Controls.CheckBox {
        id: clock24Hour
        text: i18n("Use 24-hour time")
    }
    Controls.ComboBox {
        id: green
        Kirigami.FormData.label: i18n("Green palette")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Classic"), value: "classic" },
            { text: i18n("Lime"), value: "lime" },
            { text: i18n("Emerald"), value: "emerald" },
            { text: i18n("Teal"), value: "teal" }
        ]
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Animation speed")
        Controls.Slider {
            id: speed
            from: 1
            to: 30
            stepSize: 1
            Layout.fillWidth: true
        }
        Controls.Label {
            text: (speed.value / 10).toFixed(1) + "x"
            Layout.minimumWidth: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }
    }
    Controls.SpinBox {
        id: beamWidth
        Kirigami.FormData.label: i18n("Beam width")
        from: 5
        to: 60
    }
    }
}
