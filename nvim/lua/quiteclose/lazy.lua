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

require("lazy").setup({
  spec = {

    -- Completion Engine --
    -- Uses the LSP to build a pop-up menu for code completion
    -- https://github.com/hrsh7th/nvim-cmp
    --
    {
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
          mapping = cmp.mapping.preset.insert({
            ['C-j'] = cmp.mapping.select_next_item(),
            ['C-k'] = cmp.mapping.select_prev_item(),
            ['C-l'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          }, {
            { name = 'buffer' },
            { name = 'path' },
          }),
        })
      end,
    },

    -- Copilot --
    -- GitHub Copilot integration for Neovim
    -- https://github.com/github/copilot.vim
    {
      'github/copilot.vim',
      lazy = false,
    },

    -- Fugitive --
    -- Git integration for Neovim
    -- https://github.com/tpope/vim-fugitive
    'tpope/vim-fugitive',

    -- Harpoon --
    -- Quickly switch between files
    -- https://github.com/theprimeagen/harpoon
    {
      'theprimeagen/harpoon',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- LSP Config --
    -- Native Neovim LSP configuration
    -- https://github.com/neovim/nvim-lspconfig
    {
      'neovim/nvim-lspconfig',
      config = function()
        local lspconfig = require("lspconfig")
        lspconfig.lua_ls.setup {}
        lspconfig.gopls.setup {}
        lspconfig.tsserver.setup {}
      end,
    },

    -- Lualine --
    -- Allows other plugins to add to a statusline
    -- https://github.com/nvim-lualine/lualine.nvim
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
    },

    -- Mason --
    -- Manage and install LSP servers, DAPs, linters, and formatters
    -- https://github.com/williamboman/mason.nvim
    {
      'williamboman/mason.nvim',
      config = true,
    },

    -- Mason LSPConfig --
    -- Bridge between mason.nvim and lspconfig
    -- https://github.com/williamboman/mason-lspconfig.nvim
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = {
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
      },
      config = function()
        require('mason-lspconfig').setup({
          ensure_installed = { "lua_ls", "gopls", "tsserver" },
          automatic_installation = true,
        })
      end,
    },

    -- Mini --
    -- A collection of small, focused plugins for Neovim
    -- https://github.com/echasnovski/mini.nvim
    {
      'echasnovski/mini.nvim',
      lazy = false,
    },

    -- Navic --
    -- Breadcrumb-like trail of whatever the cursor is over (see: Lualine)
    -- https://github.com/SmiteshP/nvim-navic
    {
      'SmiteshP/nvim-navic',
      dependencies = { 'neovim/nvim-lspconfig' },
    },

    -- Solarized --
    -- Colourscheme (supports both dark and light modes)
    -- https://github.com/maxmx03/solarized.nvim
    {
      'maxmx03/solarized.nvim',
      lazy = false,
      config = function()
        vim.o.background = 'dark'
        vim.cmd.colorscheme('solarized')
      end,
    },

    -- Telescope --
    -- Pop-up window for fuzzy-finding files, text, etc.
    -- https://github.com/nvim-telescope/telescope.nvim
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
    },

    -- Treesitter --
    -- Builds a syntax-tree to enable highlighting, folding, etc.
    -- https://github.com/nvim-treesitter/nvim-treesitter
    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main', lazy = false, build = ":TSUpdate",
    },

    -- Undotree --
    -- Visualize and manage undo history with :UndotreeToggle
    -- https://github.com/mbbill/undotree
    {
      'mbbill/undotree',
      lazy = false,
    },

  },
  install = { colorscheme = { "solarized" } },

  -- automatically check for plugin updates
  checker = { enabled = true },
})
