return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
    },
  },
  config = function()
    require('quiteclose/keymap').after_plugin_telescope()
  end,
}
