-- Catppuccin Mocha com fundo preto puro: combina com o kitty (fundo preto)
-- e com o tema catppuccin-black do tmux e do starship.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          base = "#000000", -- fundo do editor
          mantle = "#0a0a0a", -- barras laterais, statusline
          crust = "#000000",
          surface0 = "#1a1a1a", -- linha do cursor, popups
          surface1 = "#262626", -- seleção
          surface2 = "#333333",
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    -- "catppuccin-mocha" e não "catppuccin": o Neovim já vem com um
    -- colors/catppuccin.vim embutido que ganharia do plugin no startup.
    opts = { colorscheme = "catppuccin-mocha" },
  },
}
