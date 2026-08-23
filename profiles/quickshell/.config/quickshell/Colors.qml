pragma Singleton
import QtQuick

QtObject {
    // Base
    readonly property color background: "#000000"
    readonly property color backgroundAlt: "#0a0a0a"   // leve variação p/ cards/painéis

    // Accent
    readonly property color accent: "#00f0ff"           // azul neon
    readonly property color accentDim: "#0090a0"        // versão mais escura p/ hover/inativo

    // Texto
    readonly property color textPrimary: "#e0e0e0"
    readonly property color textMuted: "#808080"

    // Estados
    readonly property color danger: "#ff3b3b"           // mantendo seu vermelho do powermenu
    readonly property color success: "#00ff9c"
}
