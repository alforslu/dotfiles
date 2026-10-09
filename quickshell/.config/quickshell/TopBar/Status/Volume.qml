import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../.."

Rectangle {
    id: volumeSection

    color: tap.pressed ? Theme.pressedColor : hover.hovered ? Theme.hoverColor : "transparent"
    radius: Theme.defaultRadius
    implicitWidth: label.implicitWidth + Theme.sectionHorizontalPadding
    implicitHeight: label.implicitHeight

    HoverHandler {
        id: hover
    }

    TapHandler {
        id: tap
        onTapped: Quickshell.execDetached(["pavucontrol"])
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property var audio: sink?.ready ? sink.audio : null

    readonly property int percent: Math.round((audio?.volume ?? 0) * 100)

    readonly property bool muted: audio?.muted ?? false

    readonly property string icon: {
        if (!audio)
            return "";
        if (muted)
            return "";
        if (percent === 0)
            return "";
        if (percent <= 33)
            return "";
        if (percent <= 66)
            return "";
        return "";
    }

    PwObjectTracker {
        objects: [volumeSection.sink]
    }

    Text {
        id: label
        anchors.centerIn: parent
       text: !volumeSection.audio ? "N/A" : volumeSection.muted ? volumeSection.icon : volumeSection.icon + " " + volumeSection.percent + "%"
        font: Theme.defaultFont
        color: Theme.textColor
    }
}
