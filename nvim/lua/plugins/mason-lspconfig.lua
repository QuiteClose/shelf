return {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    'williamboman/mason.nvim',
    'neovim/nvim-lspconfig',
  },
  config = function()
    require('mason-lspconfig').setup({
      automatic_installation = true,
      ensure_installed = {
        'bashls',
        'gopls',
        'html',
        'jsonls',
        'lua_ls',
        'marksman',
        'pylsp',
        'rust_analyzer',
        'ts_ls',
        'yamlls',
        'zls',
      },
    })
  end,
}
