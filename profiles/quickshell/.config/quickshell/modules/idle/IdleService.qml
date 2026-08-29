import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// UNIFICAÇÃO PARCIAL (decisão consciente, não é lacuna):
//   300s -> lock (migrado pro Quickshell, WlSessionLock)
//   330s -> DPMS — permanece no hypridle (reduzido), NÃO migrado aqui.
//           Motivo: "hyprctl dispatch dpms off" digitado manualmente quebra
//           com a mesma sintaxe Lua já documentada no projeto, mas o
//           hypridle consegue disparar isso corretamente por um caminho
//           que não identificamos com certeza. Como já funciona de forma
//           comprovada, decidiu-se não reinventar — inclusive o próprio
//           Omarchy Quattro (que reescreveu isso em Quickshell) tem bugs
//           reais de DPMS/blank em produção (issues #7652, #8114 do
//           basecamp/omarchy), confirmando que essa área é frágil mesmo
//           pra quem tem mais recursos. Ver hypridle.conf reduzido.
//   900s -> suspend (migrado pro Quickshell — não depende de hyprctl
//           dispatch, só de systemctl, então não tem essa fragilidade)
//
// A cobertura do antigo "before_sleep_cmd" (travar antes de QUALQUER
// suspend, não só o disparado por idle — ex: tampa do notebook) fica a
// cargo do hypridle.conf reduzido, que agora chama o lock daqui via IPC
// (qs ipc call lock lock) em vez de invocar o hyprlock antigo.

Item {
    id: root
    property var sessionLock // referência à WlSessionLock, passada de fora (shell.qml)

    // Estágio 1 — 300s: travar a sessão
    IdleMonitor {
        timeout: 300
        onIsIdleChanged: {
            if (isIdle && root.sessionLock && !root.sessionLock.locked) {
                root.sessionLock.locked = true
            }
        }
    }

    // Estágio 2 (330s, DPMS) fica no hypridle.conf reduzido — ver nota acima.

    // Estágio 3 — 900s: suspender (já deve estar travado desde os 300s,
    // mas trava de novo por garantia, replicando o before_sleep_cmd)
    IdleMonitor {
        timeout: 900
        onIsIdleChanged: {
            if (isIdle) {
                if (root.sessionLock && !root.sessionLock.locked) {
                    root.sessionLock.locked = true
                }
                suspendProc.command = ["systemctl", "suspend"]
                suspendProc.running = true
            }
        }
    }

    Process { id: suspendProc }
}
