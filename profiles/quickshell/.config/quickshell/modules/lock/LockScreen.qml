import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io
import "../../"

// ⚠️ ARQUIVO CRÍTICO DE SEGURANÇA — ler as notas de incerteza antes de usar
// como substituto real do hyprlock. NÃO remover hyprlock.conf/hypridle.conf
// do sistema até isso ser validado extensivamente (idealmente com uma
// segunda sessão SSH aberta em paralelo, pra conseguir matar o processo se
// travar em vez de precisar de reboot forçado).
//
// ESTRUTURA (2ª tentativa, baseada num exemplo real de produção —
// caelestia-shell): WlSessionLock e PamContext ficam como IRMÃOS dentro de
// um Scope, não um aninhado dentro do outro. A 1ª tentativa (PamContext
// aninhado dentro do WlSessionLock, junto com a surface) causava o erro
// "WlSessionLock.surface does not create a WlSessionLockSurface" — a
// mistura de tipos de filho parece confundir a resolução da property
// default "surface" do WlSessionLock.

Scope {
    id: root

    property alias locked: sessionLock.locked
    property string passwordBuffer: ""
    property string errorMessage: ""
    property bool authenticating: false

    WlSessionLock {
        id: sessionLock

        WlSessionLockSurface {
            id: lockSurface
            color: "#000000" // Colors.background

            Column {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    text: "LOCKED"
                    color: "#00f0ff" // Colors.accent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 24
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: 320
                    height: 44
                    color: "transparent"
                    border.color: "#00f0ff"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "*".repeat(root.passwordBuffer.length)
                        color: "#e0e0e0" // Colors.textPrimary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                }

                Text {
                    text: root.errorMessage
                    color: "#ff3b3b" // Colors.danger
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.errorMessage.length > 0
                }

                Text {
                    text: root.authenticating ? "verificando..." : " "
                    color: "#808080" // Colors.textMuted
                    font.pixelSize: 11
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // captura de teclado — precisa de foco explícito na surface travada
            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.tryUnlock()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Backspace) {
                        root.passwordBuffer = root.passwordBuffer.slice(0, -1)
                        event.accepted = true
                    } else if (event.text.length > 0) {
                        root.passwordBuffer += event.text
                        event.accepted = true
                    }
                }
            }
        }
    }

    PamContext {
        id: pam
        // ⚠️ precisa existir /etc/pam.d/quickshell-lock — copiar o padrão
        // do /etc/pam.d/hyprlock que já existe e já funciona no seu sistema
        config: "quickshell-lock"
        user: "bielzao" // ajustar se o usuário do sistema for outro

        onCompleted: function(result) {
            root.authenticating = false
            if (result === PamResult.Success) {
                root.errorMessage = ""
                root.passwordBuffer = ""
                sessionLock.locked = false
            } else {
                root.errorMessage = "Senha incorreta"
                root.passwordBuffer = ""
            }
        }
        onError: function(error) {
            root.authenticating = false
            root.errorMessage = "Erro de autenticação"
        }
    }

    function tryUnlock() {
        if (authenticating || passwordBuffer.length === 0) return
        authenticating = true
        errorMessage = ""

        // ⚠️ PONTO DE MAIOR INCERTEZA DO ARQUIVO INTEIRO:
        // não tenho certeza absoluta de qual é o mecanismo certo pra
        // entregar a senha digitada ao PamContext. As duas hipóteses mais
        // prováveis, baseadas em padrões de outros consumidores de PAM:
        //   (a) uma property/method direto tipo pam.respond(passwordBuffer)
        //       chamado antes ou depois de pam.start()
        //   (b) um handler disparado pelo próprio PAM quando ele pede o
        //       auth token, e a resposta só pode ser enviada DENTRO desse
        //       handler
        // Comecei pela hipótese (a) abaixo. Se o log do Quickshell mostrar
        // erro de propriedade/método inexistente em PamContext, é sinal de
        // trocar pra abordagem (b) — me manda o erro exato que ajusto.
        pam.respond(passwordBuffer)
        pam.start()
    }
}
