return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require('nvim-treesitter.configs').setup{
        ensure_installed = {
          'bash',
          'c',
          'clojure',
          'cpp',
          'css',
          'dockerfile',
          'elixir',
          'erlang',
          'git_config',
          'git_rebase',
          'gitcommit',
          'gitignore',
          'go',
          'haskell',
          'hcl',
          'html',
          'ini',
          'java',
          'javascript',
          'json',
          'lua',
          'make',
          'markdown',
          'perl',
          'php',
          'python',
          'r',
          'regex',
          'ruby',
          'rust',
          'scala',
          'scss',
          'sql',
          'swift',
          'terraform',
          'todotxt',
          'toml',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'vue',
          'xml',
          'yaml',
          'zig',
        },
        sync_install = false,
        auto_install = true,
        ignore_install = { 'ipkg' },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
      -- Add todotxt parser configuration
      local success, parser_config = pcall(function()
        return require("nvim-treesitter.parsers").get_parser_configs()
      end)
      if success and parser_config then
        parser_config.todotxt = {
          install_info = {
            url = "https://github.com/arnarg/tree-sitter-todotxt",
            files = {"src/parser.c"},
            branch = "main",
          },
          filetype = "todotxt",
        }
      end
    end,
  },
}
