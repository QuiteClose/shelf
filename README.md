# NeoVim (and Vim) Config

## NeoVim Installation

```bash
mkdir ~/etc
git clone https://github.com/quiteclose/vimrc.git ~/etc/vimrc
ln -s ~/etc/vimrc/neovim/nvim ~/.config/nvim
mkdir ~/.nvimundo
```

## NeoVim IDE Installation
```bash
mkdir ~/etc
git clone https://github.com/quiteclose/vimrc.git ~/etc/vimrc
ln -s ~/etc/vimrc/neovim.ide/nvim ~/.config/nvim
mkdir ~/.nvimundo
```
*   Install packer: https://github.com/wbthomason/packer.nvim
    *   Clone the plugin:
        ```
        git clone --depth 1 https://github.com/wbthomason/packer.nvim\
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
        ```
    *   Open neovim and run the command:
        ```
        :PackerSync
        ```
*   Install CoPilot




## Vim (deprecated)
**See vim sub-directory README.**

NeoVim migration deprecated Vim config as of May 2022. The following guide
was helpful with the migration:

*   [Migrating from vim to neovim](https://otavio.dev/2018/09/30/migrating-from-vim-to-neovim/) by Valadares.

