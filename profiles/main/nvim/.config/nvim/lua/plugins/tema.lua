-- Tema = paleta do kitty. O repinta gera lua/tema-atual.lua (fora do git) com
-- as cores do preset ativo, e o mini.base16 monta o colorscheme a partir dele.
-- Trocou o `cor`, o repinta chama Repinta() em todo nvim aberto (via socket).

local arquivo = vim.fn.stdpath("config") .. "/lua/tema-atual.lua"

-- Global de propósito: é o que o repinta chama por --remote-expr
function _G.Repinta()
  local ok, paleta = pcall(dofile, arquivo)
  if not ok then
    -- Sem o arquivo (máquina nova antes do setup.sh): ANSI puro do terminal
    vim.o.termguicolors = false
    vim.cmd.colorscheme("default")
    return
  end
  vim.o.termguicolors = true
  require("mini.base16").setup({ palette = paleta, use_cterm = true })
  vim.g.colors_name = "tema-atual"

  -- Plano como o resto do desktop: um fundo só, borda 1px no apagado.
  -- base01 fica só na linha do cursor e no menu de completar.
  local hl = function(nome, o) vim.api.nvim_set_hl(0, nome, o) end
  local calha = { "SignColumn", "LineNr", "LineNrAbove", "LineNrBelow", "FoldColumn", "CursorLineNr" }
  for _, g in ipairs(calha) do
    hl(g, vim.tbl_extend("force", vim.api.nvim_get_hl(0, { name = g }), { bg = "NONE" }))
  end
  hl("NormalFloat", { fg = paleta.base05, bg = paleta.base00 })
  hl("FloatBorder", { fg = paleta.base02, bg = paleta.base00 })
  hl("FloatTitle", { fg = paleta.base04, bg = paleta.base00 })
  hl("WinSeparator", { fg = paleta.base02, bg = "NONE" })
  -- Fundo da statusline fora dos blocos da lualine (o Trouble cai nele)
  hl("StatusLine", { fg = paleta.base05, bg = paleta.base00 })
  hl("StatusLineNC", { fg = paleta.base03, bg = paleta.base00 })

  vim.g.tema_paleta = paleta
  -- O mini.base16 não dispara o evento; a lualine se refaz com ele
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "tema-atual" })
end

-- Statusline como a waybar: fundo da paleta, só o modo em bloco invertido
local function lualine_tema()
  local p = vim.g.tema_paleta
  if not p then
    return "auto"
  end
  local modo = function(cor)
    return {
      a = { fg = p.base00, bg = cor },
      b = { fg = p.base05, bg = p.base00 },
      c = { fg = p.base05, bg = p.base00 },
    }
  end
  local apagado = { fg = p.base03, bg = p.base00 }
  return {
    normal = modo(p.base04),
    insert = modo(p.base0B),
    visual = modo(p.base0E),
    replace = modo(p.base08),
    command = modo(p.base0A),
    inactive = { a = apagado, b = apagado, c = apagado },
  }
end

return {
  { "nvim-mini/mini.base16", lazy = false, priority = 1000 },
  { "LazyVim/LazyVim", opts = { colorscheme = Repinta } },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = lualine_tema
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }
    end,
  },
  -- Os temas que o LazyVim traz de fábrica não são usados
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
}
