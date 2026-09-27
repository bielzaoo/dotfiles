// Layout dos painéis do Plasma: barra fina no topo + dock flutuante embaixo.
// Executado pelo setup.sh via D-Bus (org.kde.PlasmaShell.evaluateScript).
// ATENÇÃO: remove todos os painéis existentes antes de recriar.

panels().forEach(function (p) {
    p.remove();
});

// ---- Barra superior: menu + áreas de trabalho | relógio | bandeja ----
var bar = new Panel();
bar.location = "top";
bar.height = 28;
bar.floating = false;
bar.lengthMode = "fill";
bar.hiding = "none";

var menu = bar.addWidget("org.kde.plasma.kickoff");
menu.currentConfigGroup = ["General"];
// logo do Arch em branco, instalado pelo setup.sh (caminho direto evita
// depender do cache de ícones do Plasma)
menu.writeConfig("icon", userDataPath("data", "icons/hicolor/scalable/apps/archlinux-logo-white.svg"));
bar.addWidget("org.kde.plasma.pager");
bar.addWidget("org.kde.plasma.panelspacer");

var clock = bar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", 1); // data ao lado da hora
clock.writeConfig("dateFormat", "custom");
clock.writeConfig("customDateFormat", "ddd d MMM");

bar.addWidget("org.kde.plasma.panelspacer");
bar.addWidget("org.kde.plasma.systemtray");

// ---- Dock: só apps; flutuante, centralizada, some quando uma janela encosta ----
var dock = new Panel();
dock.location = "bottom";
dock.height = 48;
dock.floating = true;
dock.lengthMode = "fit";
dock.alignment = "center";
dock.hiding = "dodgewindows";

var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:kitty.desktop",
    "applications:org.kde.kate.desktop",
    "applications:org.kde.discover.desktop",
    "applications:systemsettings.desktop",
].join(","));
