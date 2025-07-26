return {
  'neovim/nvim-lspconfig',
  config = function()
    local lspconfig = require('lspconfig')

    lspconfig.lua_ls.setup({
      on_attach = require('quiteclose/keymap').on_lsp_attach,
    })

    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = {
                'E125',
                'E221',
                'E225',
                'E226',
                'E302',
                'E305',
                'E501',
                'W391',
              },
              maxLineLength = 100,
            },
          },
        },
      },
    })
  end,
}
