-- Plugins installed via ../lua/quiteclose/lazy.lua

local cmp        = require('cmp')
local luasnip    = require('luasnip')
local navic      = require("nvim-navic")
local keymap     = require('quiteclose.keymap')

-- Mason LSP Setup -------------------------------
require('mason-lspconfig').setup {
  automatic_installation = true,
  ensure_installed = {
    --'bashls',
    --'django-template-lsp',
    --'gopls',
    --'html',
    --'jsonls',
    --'lua_ls',
    --'marksman',
    --'pylsp',
    --'ruby_lsp',
    --'rust_analyzer',
    --'ts_ls',
    --'yamlls',
    --'zls',
  },
}

-- LSP Config ------------------------------------
require('lspconfig').lua_ls.setup {
  on_attach = keymap.on_lsp_attach,
}

-- LSP Config: pylsp -----------------------------
require('lspconfig').pylsp.setup {
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
          maxLineLength = 100
        }
      }
    }
  }
}

-- cmp Completion Setup --------------------------
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = keymap.cmp_mapping(),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
}

-- navic LuaLine Setup ---------------------------
require("lualine").setup {
  sections = {
    lualine_c = {
      {
        function()
          return navic.get_location()
        end,
        cond = function()
          return navic.is_available()
        end
      },
    }
  }
}

navic.setup {
  icons = {
    File          = "󰈙 ",
    Module        = " ",
    Namespace     = "󰌗 ",
    Package       = " ",
    Class         = "󰌗 ",
    Method        = "󰆧 ",
    Property      = " ",
    Field         = " ",
    Constructor   = " ",
    Enum          = "󰕘",
    Interface     = "󰕘",
    Function      = "󰊕 ",
    Variable      = "󰆧 ",
    Constant      = "󰏿 ",
    String        = "󰀬 ",
    Number        = "󰎠 ",
    Boolean       = "◩ ",
    Array         = "󰅪 ",
    Object        = "󰅩 ",
    Key           = "󰌋 ",
    Null          = "󰟢 ",
    EnumMember    = " ",
    Struct        = "󰌗 ",
    Event         = " ",
    Operator      = "󰆕 ",
    TypeParameter = "󰊄 ",
  },
  lsp = {
    auto_attach = true,
    preference = nil,
  },
  highlight = false,
  separator = " > ",
  depth_limit = 0,
  depth_limit_indicator = "..",
  safe_output = true,
  lazy_update_context = false,
  click = false,
  format_text = function(text)
    return text
  end,
}
