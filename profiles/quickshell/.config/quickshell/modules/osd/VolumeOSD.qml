import QtQuick
import Quickshell.Services.Pipewire
import "../../components"

OSDBar {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink ? sink.audio.volume : 0
    readonly property bool muted: sink ? sink.audio.muted : false

    value: muted ? 0 : volume
    danger: muted
    label: muted ? "MUTE" : Math.round(volume * 100) + "%"

    PwObjectTracker {
        objects: sink ? [sink] : []
    }

    function nudge(delta) {
        if (!sink) return
        sink.audio.muted = false
        sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta))
        root.show()
    }

    function toggleMute() {
        if (!sink) return
        sink.audio.muted = !sink.audio.muted
        root.show()
    }
}
