return {
  'tpope/vim-fugitive',
  config = function()
    require('quiteclose/keymap').after_plugin_fugitive()
  end,
}
