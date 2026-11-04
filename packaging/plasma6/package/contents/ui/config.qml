import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Plasma injects configDialog and wallpaperConfiguration into this root Item.
// Keep the form layout nested so those properties exist on the expected object.
Item {
    id: root
    property var configDialog
    property var wallpaperConfiguration

    property alias cfg_showClock: showClock.checked
    property alias cfg_showDate: showDate.checked
    property alias cfg_clock24Hour: clock24Hour.checked
    property string cfg_green: "emerald"
    property alias cfg_beamWidth: beamWidth.value
    property alias cfg_speed: speed.value
    property alias cfg_orbs: orbs.value
    property string cfg_shape: "oval"
    property string cfg_direction: "random"
    property alias cfg_glow: glow.value
    property alias cfg_orbBrightness: orbBrightness.value
    property alias cfg_orbitSize: orbitSize.value
    property alias cfg_trailLength: trailLength.value
    property alias cfg_flameIntensity: flameIntensity.value
    property alias cfg_blankDuration: blankDuration.value

    implicitWidth: form.implicitWidth
    implicitHeight: form.implicitHeight

    Kirigami.FormLayout {
        id: form
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
            currentIndex: Math.max(0, indexOfValue(root.cfg_green))
            onActivated: root.cfg_green = currentValue
            model: [
                { text: i18n("Classic"), value: "classic" },
                { text: i18n("Lime"), value: "lime" },
                { text: i18n("Emerald"), value: "emerald" },
                { text: i18n("Teal"), value: "teal" },
                { text: i18n("Ice blue"), value: "ice" },
                { text: i18n("Amber"), value: "amber" },
                { text: i18n("Violet"), value: "violet" },
                { text: i18n("White"), value: "white" }
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
        Controls.ComboBox {
            id: shape
            Kirigami.FormData.label: i18n("Orbit shape")
            textRole: "text"
            valueRole: "value"
            currentIndex: Math.max(0, indexOfValue(root.cfg_shape))
            onActivated: root.cfg_shape = currentValue
            model: [
                { text: i18n("Oval"), value: "oval" },
                { text: i18n("Circle"), value: "circle" },
                { text: i18n("Wide oval"), value: "wide" },
                { text: i18n("Tall oval"), value: "tall" }
            ]
        }
        Controls.ComboBox {
            id: direction
            Kirigami.FormData.label: i18n("Travel direction")
            textRole: "text"
            valueRole: "value"
            currentIndex: Math.max(0, indexOfValue(root.cfg_direction))
            onActivated: root.cfg_direction = currentValue
            model: [
                { text: i18n("Random (changes every orbit)"), value: "random" },
                { text: i18n("Clockwise"), value: "clockwise" },
                { text: i18n("Counterclockwise"), value: "counterclockwise" }
            ]
        }
        Controls.SpinBox {
            id: orbs
            Kirigami.FormData.label: i18n("Number of orbs")
            from: 1
            to: 8
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Glow intensity")
            Controls.Slider { id: glow; from: 10; to: 100; stepSize: 5; Layout.fillWidth: true }
            Controls.Label { text: glow.value + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Orb brightness")
            Controls.Slider { id: orbBrightness; from: 10; to: 200; stepSize: 5; Layout.fillWidth: true }
            Controls.Label { text: orbBrightness.value + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Orbit size")
            Controls.Slider { id: orbitSize; from: 50; to: 120; stepSize: 5; Layout.fillWidth: true }
            Controls.Label { text: orbitSize.value + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Trail length")
            Controls.Slider { id: trailLength; from: 5; to: 100; stepSize: 5; Layout.fillWidth: true }
            Controls.Label { text: trailLength.value + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Flame intensity")
            Controls.Slider { id: flameIntensity; from: 0; to: 200; stepSize: 5; Layout.fillWidth: true }
            Controls.Label { text: flameIntensity.value + "%" }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Blackout duration")
            Controls.Slider { id: blankDuration; from: 0; to: 60; stepSize: 1; Layout.fillWidth: true }
            Controls.Label { text: blankDuration.value + " sec" }
        }
        Controls.SpinBox {
            id: beamWidth
            Kirigami.FormData.label: i18n("Beam width")
            from: 5
            to: 60
        }
    }
}