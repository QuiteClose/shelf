return {
  'neovim/nvim-lspconfig',
  ensure_installed = { "todotxt" },
  config = function()
    vim.lsp.config('lua_ls', {
      on_attach = require('quiteclose/keymap').on_lsp_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    })
    vim.lsp.config('pylsp', {
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = {
                'E125', --continuation line with same indent as next logical line
                'E221', --multiple spaces before operator
                'E225', --missing whitespace around operator
                'E226', --missing whitespace around arithmetic operator
                'E302', --expected 2 blank lines, found 1
                'E305', --expected 2 blank lines after class or function definition
                'E501', --line too long
                'W391', --blank line at end of file
              },
              maxLineLength = 100,
            },
          },
        },
      },
    })
  end,
}
