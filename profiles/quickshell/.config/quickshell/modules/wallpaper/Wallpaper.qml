import QtQuick
import Quickshell
import Quickshell.Wayland

// Módulo de baixo risco (puramente visual, sem segurança envolvida).
// Usa a mesma attached property já validada no resto do projeto:
// WlrLayershell.layer (não "PanelWindow.layer", que não existe — ver nota
// no CLAUDE.md).

PanelWindow {
    WlrLayershell.layer: WlrLayer.Background
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Image {
        anchors.fill: parent
        source: "file:///home/bielzao/Pictures/wallpapers/default.jpg"
        fillMode: Image.PreserveAspectCrop
        cache: true
    }
}
