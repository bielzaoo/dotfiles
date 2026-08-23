return {
  'vim-test/vim-test',
  keys = {
    { 'n', '<leader>t', ':TestNearest<CR>' },
    { 'n', '<leader>T', ':TestFile<CR>' },
    { 'n', '<leader>a', ':TestSuite<CR>' },
    { 'n', '<leader>l', ':TestLast<CR>' },
    { 'n', '<leader>g', ':TestVisit<CR>' },
  },
}
