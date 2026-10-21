-- Vantablack (github.com/bjarneo/vantablack.nvim): tons de cinza, fundo
-- #0d0d0d. O kitty e o tmux usam o vantablack.conf com o mesmo fundo, pra
-- não aparecer moldura entre o Neovim e o terminal.
return {
  {
    "bjarneo/vantablack.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "vantablack" },
  },
}
