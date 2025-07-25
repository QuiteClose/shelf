-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  -- Telescope
  {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
      vim.keymap.set('n', '<C-p>', builtin.git_files, {})
      vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
      vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/playground' },
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        sync_install = false,
        auto_install = true,
        ignore_install = { "ipkg" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end
  },

  -- Mini.nvim
  'echasnovski/mini.nvim',

  -- Harpoon
  {
    'theprimeagen/harpoon',
    config = function()
      local mark = require('harpoon.mark')
      local ui = require('harpoon.ui')

      vim.keymap.set('n', '<leader>a', mark.add_file)
      vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

      vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
      vim.keymap.set('n', '<C-j>', function() ui.nav_prev() end)
      vim.keymap.set('n', '<C-k>', function() ui.nav_next() end)
      vim.keymap.set('n', '<C-l>', function() ui.nav_file(2) end)
    end
  },

  -- Undotree
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
    end
  },

  -- Fugitive
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
    end
  },

  -- Copilot
  'github/copilot.vim',

  -- LSP Zero and related plugins
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      local lsp_zero = require('lsp-zero')

      lsp_zero.on_attach(function(client, bufnr)
        local opts = {buffer = bufnr, remap = false}

        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      end)

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = {'pylsp', 'rust_analyzer'},
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        }
      })

      require('lspconfig').pylsp.setup{
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

      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}

      cmp.setup({
        sources = {
          {name = 'path'},
          {name = 'nvim_lsp'},
          {name = 'nvim_lua'},
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
      })
    end
  },

  -- Solarized colorscheme
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'solarized'
      
      -- Also set up the ColorMyPencils function for compatibility
      function ColorMyPencils(color) 
        color = color or "solarized"
        vim.cmd.colorscheme(color)
      end
      ColorMyPencils()
    end
  },

  -- Lualine
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 
      'nvim-tree/nvim-web-devicons',
      'SmiteshP/nvim-navic'
    },
    config = function()
      local navic = require("nvim-navic")

      require("lualine").setup({
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
      })

      navic.setup {
          icons = {
              File          = "󰈙 ",
              Module        = " ",
              Namespace     = "󰌗 ",
              Package       = " ",
              Class         = "󰌗 ",
              Method        = "󰆧 ",
              Property      = " ",
              Field         = " ",
              Constructor   = " ",
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
              EnumMember    = " ",
              Struct        = "󰌗 ",
              Event         = " ",
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
    end
  },

  -- nvim-navic (separate entry for proper dependency handling)
  {
    "SmiteshP/nvim-navic",
    dependencies = "neovim/nvim-lspconfig"
  }
})