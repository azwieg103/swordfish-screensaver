import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

// Plain Qt Quick layout for the Screen Locking KCM.
// Avoid Kirigami.FormLayout: the KCM logs a null-children error while
// constructing that layout, which prevents the complete settings form loading.
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

    implicitWidth: 640
    implicitHeight: Math.min(settingsColumn.implicitHeight + 16, 560)

    Controls.ScrollView {
        id: settingsScroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        contentHeight: settingsColumn.implicitHeight

        ColumnLayout {
            id: settingsColumn
            width: settingsScroll.availableWidth
            spacing: 10

            Controls.CheckBox {
                id: showClock
                text: qsTr("Show time")
                Layout.fillWidth: true
            }
            Controls.CheckBox {
                id: showDate
                text: qsTr("Show date above time")
                Layout.fillWidth: true
            }
            Controls.CheckBox {
                id: clock24Hour
                text: qsTr("Use 24-hour time")
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Color theme"); Layout.preferredWidth: 190 }
                Controls.ComboBox {
                    id: green
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: Math.max(0, indexOfValue(root.cfg_green))
                    onActivated: root.cfg_green = currentValue
                    model: [
                        { text: qsTr("Classic"), value: "classic" },
                        { text: qsTr("Lime"), value: "lime" },
                        { text: qsTr("Emerald"), value: "emerald" },
                        { text: qsTr("Teal"), value: "teal" },
                        { text: qsTr("Ice blue"), value: "ice" },
                        { text: qsTr("Amber"), value: "amber" },
                        { text: qsTr("Violet"), value: "violet" },
                        { text: qsTr("White"), value: "white" },
                        { text: qsTr("Fireball (red/orange)"), value: "fireball" }
                    ]
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Animation speed"); Layout.preferredWidth: 190 }
                Controls.Slider { id: speed; from: 1; to: 30; stepSize: 1; Layout.fillWidth: true }
                Controls.Label { text: (speed.value / 10).toFixed(1) + "x"; Layout.minimumWidth: 42 }
            }

            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Orbit shape"); Layout.preferredWidth: 190 }
                Controls.ComboBox {
                    id: shape
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    currentIndex: Math.max(0, indexOfValue(root.cfg_shape))
                    onActivated: root.cfg_shape = currentValue
                    model: [
                        { text: qsTr("Oval"), value: "oval" },
                        { text: qsTr("Circle"), value: "circle" },
                        { text: qsTr("Wide oval"), value: "wide" },
                        { text: qsTr("Tall oval"), value: "tall" }
                    ]
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Controls.Label { text: qsTr("Travel direction") }
                Controls.ButtonGroup { id: directionGroup }
                Controls.RadioButton {
                    text: qsTr("Random (alternate every three cycles)")
                    checked: root.cfg_direction === "random"
                    ButtonGroup.group: directionGroup
                    onToggled: if (checked) root.cfg_direction = "random"
                }
                Controls.RadioButton {
                    text: qsTr("Clockwise")
                    checked: root.cfg_direction === "clockwise"
                    ButtonGroup.group: directionGroup
                    onToggled: if (checked) root.cfg_direction = "clockwise"
                }
                Controls.RadioButton {
                    text: qsTr("Counterclockwise")
                    checked: root.cfg_direction === "counterclockwise"
                    ButtonGroup.group: directionGroup
                    onToggled: if (checked) root.cfg_direction = "counterclockwise"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Number of orbs"); Layout.preferredWidth: 190 }
                Controls.SpinBox { id: orbs; from: 1; to: 8 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Meteor flame intensity"); Layout.preferredWidth: 190 }
                Controls.Slider { id: flameIntensity; from: 0; to: 200; stepSize: 5; Layout.fillWidth: true }
                Controls.Label { text: flameIntensity.value + "%"; Layout.minimumWidth: 42 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Glow intensity"); Layout.preferredWidth: 190 }
                Controls.Slider { id: glow; from: 10; to: 100; stepSize: 5; Layout.fillWidth: true }
                Controls.Label { text: glow.value + "%"; Layout.minimumWidth: 42 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Orb brightness"); Layout.preferredWidth: 190 }
                Controls.Slider { id: orbBrightness; from: 10; to: 200; stepSize: 5; Layout.fillWidth: true }
                Controls.Label { text: orbBrightness.value + "%"; Layout.minimumWidth: 42 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Orbit size"); Layout.preferredWidth: 190 }
                Controls.Slider { id: orbitSize; from: 50; to: 120; stepSize: 5; Layout.fillWidth: true }
                Controls.Label { text: orbitSize.value + "%"; Layout.minimumWidth: 42 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Trail length"); Layout.preferredWidth: 190 }
                Controls.Slider { id: trailLength; from: 5; to: 100; stepSize: 5; Layout.fillWidth: true }
                Controls.Label { text: trailLength.value + "%"; Layout.minimumWidth: 42 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Blackout duration"); Layout.preferredWidth: 190 }
                Controls.Slider { id: blankDuration; from: 0; to: 60; stepSize: 1; Layout.fillWidth: true }
                Controls.Label { text: blankDuration.value + " sec"; Layout.minimumWidth: 54 }
            }
            RowLayout {
                Layout.fillWidth: true
                Controls.Label { text: qsTr("Beam width"); Layout.preferredWidth: 190 }
                Controls.SpinBox { id: beamWidth; from: 5; to: 60 }
            }
        }
    }
}
