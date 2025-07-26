return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'L3MON4D3/LuaSnip',
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = require('quiteclose.keymap').cmp_mapping(),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
        { name = 'path' },
      }),
    })
  end,
}
