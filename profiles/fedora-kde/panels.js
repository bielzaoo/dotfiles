// Layout dos painéis do Plasma no Fedora, no jeito do GNOME: barra fina no
// topo + dock flutuante embaixo. Executado pelo setup.sh via D-Bus
// (org.kde.PlasmaShell.evaluateScript).
// ATENÇÃO: remove todos os painéis existentes antes de recriar.

panels().forEach(function (p) {
    p.remove();
});

// ---- Barra superior: menu | relógio no centro | bandeja ----
var bar = new Panel();
bar.location = "top";
bar.height = 26;
bar.floating = false;
bar.lengthMode = "fill";
bar.hiding = "none";

// Menu com o ícone padrão do Fedora.
bar.addWidget("org.kde.plasma.kickoff");
bar.addWidget("org.kde.plasma.panelspacer");

var clock = bar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", 1); // data ao lado da hora
clock.writeConfig("dateFormat", "custom");
clock.writeConfig("customDateFormat", "ddd d MMM");

bar.addWidget("org.kde.plasma.panelspacer");
bar.addWidget("org.kde.plasma.systemtray");

// ---- Dock: só apps; flutuante, centralizada, translúcida, some quando uma
// janela encosta ----
var dock = new Panel();
dock.location = "bottom";
dock.height = 48;
dock.floating = true;
dock.lengthMode = "fit";
dock.alignment = "center";
dock.hiding = "dodgewindows";
// "adaptive" (padrão) fica opaca com janela maximizada; aqui é sempre
// translúcida, com o desfoque do KWin por trás, como o DYNAMIC do GNOME.
dock.opacity = "translucent";

var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.konsole.desktop",
    "applications:org.kde.discover.desktop",
    "applications:systemsettings.desktop",
].join(","));
