return {
  'theprimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('quiteclose/keymap').after_plugin_harpoon()
  end,
}
