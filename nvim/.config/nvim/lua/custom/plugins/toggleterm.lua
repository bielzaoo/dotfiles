return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    open_mapping = [[<A-t>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
    autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
    shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
    shading_factor = -30, -- the percentage by which to lighten dark terminal background, default: -30
    shading_ratio = -3, -- the ratio of shading factor for light/dark terminal background, default: -3
    direction = 'float',
    close_on_exit = true, -- close the terminal window when the process exits
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    float_opts = {
      -- The border key is *almost* the same as 'nvim_open_win'
      -- see :h nvim_open_win for details on borders however
      -- the 'curved' border is a custom border type
      -- not natively supported but implemented in this plugin.
      border = 'curved',
      -- border = 'single' | 'double' | 'shadow' | 'curved' |
      -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
      -- width = <value>,
      -- height = <value>,
      -- row = <value>,
      -- col = <value>,
      winblend = 3,
      -- zindex = <value>,
      title_pos = 'center',
      -- title_pos = 'left' | 'center' | 'right', position of the title of the floating window
    },
  },
  config = true,
}
