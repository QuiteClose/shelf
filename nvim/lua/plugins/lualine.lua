return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local navic = require('nvim-navic')
    require('lualine').setup({
      sections = {
        lualine_c = {
          {
            function() return navic.get_location() end,
            cond = function() return navic.is_available() end,
          },
        },
      },
    })
  end,
}
