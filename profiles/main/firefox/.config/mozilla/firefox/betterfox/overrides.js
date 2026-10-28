// Ajustes por cima do Betterfox (betterfox.js, upstream intocado). O setup.sh
// junta os dois no user.js do perfil padrão; o que estiver aqui ganha.
// Overrides comuns: https://github.com/yokoffing/Betterfox/wiki/Common-Overrides
//
// Pra atualizar o Betterfox, troque o betterfox.js pelo user.js da release
// nova (https://github.com/yokoffing/Betterfox/releases) e rode o setup.sh.

// Densidade compacta nativa (a barra única fica no userChrome.css)
user_pref("browser.uidensity", 1);

// Abas verticais nativas: a barra de abas do topo some e as abas vão pra
// lateral, só com o ícone, expandindo com o mouse em cima. Como o user.js é
// reaplicado a cada start, mudar isso pela interface não pega: troque aqui.
// Outros valores: "always-show" (sempre aberta), "hide-launcher" (some de vez)
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);
user_pref("sidebar.visibility", "expand-on-hover");

// Favoritos: Ctrl+D grava na hora (só um aviso rápido). Com o painel de
// edição, a página ficava pendente até o "Salvar" e o Esc descartava tudo,
// menos as pastas criadas no caminho. Ctrl+D numa página já salva abre o
// painel pra trocar nome/pasta.
user_pref("browser.bookmarks.editDialog.showForNewBookmarks", false);
// Barra de favoritos só na nova aba; Ctrl+Shift+B mostra/esconde até reabrir.
// Ctrl+B abre os favoritos na lateral.
user_pref("browser.toolbars.bookmarks.visibility", "newtab");
