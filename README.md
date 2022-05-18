# Vim and NeoVim configs
Vim config is deprecated as of May 2022 after migrating to neovim. The
following guides were helpful with the migration:

*   [Migrating from vim to neovim](https://otavio.dev/2018/09/30/migrating-from-vim-to-neovim/) by Valadares.

## NeoVim Installation

```bash
mkdir ~/etc
git clone https://github.com/dsclose/vimrc.git ~/etc/vimrc
ln -s ~/etc/vimrc/neovim/nvim ~/.config/nvim
mkdir ~/.vimundo
```

## Vim Installation

Features:

* HTML5 syntax highlighting.
* Relative line numbers in the gutter.
* Persistent undo history.
* Paste insert mode disables auto-indentation (toggle with F2).

Installation:

```bash
mkdir ~/etc
git clone https://github.com/dsclose/vimrc.git ~/etc/vimrc
ln -s ~/etc/vimrc/vim/vimrc ~/.vimrc
ln -s ~/etc/vimrc/vim/vim.d ~/.vim
mkdir ~/.vimundo
```


