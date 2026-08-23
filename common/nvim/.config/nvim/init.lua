-- [[ Leader Key Conf ]] ==========================
-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- ================================================

-- [[ Other components ]] =========================
require 'brain.keymaps'
require 'brain.options'
require 'brain.autocommands'

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- ================================================

-- [[ LazyVim ]] ==================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  require 'brain.plugins.debug',
  require 'brain.plugins.indent_line',
  require 'brain.plugins.lint',
  require 'brain.plugins.autopairs',
  require 'brain.plugins.neo-tree',
  require 'brain.plugins.gitsigns',
  require 'brain.plugins.guess_indent',
  require 'brain.plugins.which_key',
  require 'brain.plugins.telescope',
  require 'brain.plugins.lazydev',
  require 'brain.plugins.lspconfig',
  require 'brain.plugins.conform',
  require 'brain.plugins.blink',
  require 'brain.plugins.catppuccin',
  require 'brain.plugins.todo_comments',
  require 'brain.plugins.mini',
  require 'brain.plugins.treesitter',

  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- ================================================

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
