return {
  'mbbill/undotree',
  lazy = false,
  config = function()
    require('quiteclose.keymap').after_plugin_undotree()
  end,
}
