
# Nix
## General
- [X] fix any build warning (like nix-fmt)

- [ ] Move all vim config to lua files outside of home.nix   <<<<<<<<<<<-------------------------------


- [ ] dim inactive tmux windows   <<<<<<<<<<<-------------------------------
- [ ] dim inactive nvim windows   <<<<<<<<<<<-------------------------------

## NeoVim
### Neovim Coding

- nerd dictation integration
  - keybindings are dictation-start=?? and dictations-stop?? 
  - [ ] dication-stop not adding to clipboard

- [ ] mcp systemd auto start with direnv
- mcp servers
    - [ ] context7
    - [ ] consult7

### Neovim General
- [ ] obsidian like dataview task search   <<<<<<<<<<<-------------------------------
- [ ] mark tasks as "ready" and have github action cron job to create a PR for the ready tasks

- [ ] vim sessions (https://github.com/jedrzejboczar/possession.nvim)
    - [ ] integrate with tmux resurrect
- [ ] startup screen (alpha.nvim)
    - [ ] integrate with possession
- [ ] neovim-project with neo-tree and barbar
neovim-project will restore expanded/collapsed directories in neotree and tab order in barbar. barbar is a big improvement on tabs in neovim.

- [x] diffview shortcuts
    - [x] Keyboard shortcut to show inline diff of current buffer
    - [ ] diffview close should be <leader>gdc     <<<<<<<<<<<<<<<<<<<<<-----------------------------

- [x] neotree

- [ ] starship linux icon

- markdown
    - [ ] shift left-right on enter insert mode
    - [ ] shift left-right two spaces (not four)

- [ ] alt-h/j/k/l for lists should work in insert mode
- [ ] register " doesn't work for paste from system keyboard

- [ ] telescope <c-p/g/f> shortcuts
    - [x] grep doesn't find all files (search "neogit" for example)
    - [ ] <c-alt-g/p> to run the commands from the repo root instead of current directory   <<<<<<<<<<<-------------------------------

- [ ] nvim-dap for sveltekit

Snippets
- [ ] luasnip
## zsh
- [ ] slow startup time
- [x] replace opencode executable with "nix run ..." shortcut   <<<<<<<<<<<-------------------------------
### Starship prompt
- [ ] darker colors
- [ ] hostname instead of user name

## tmux

- [x] catpuccin theme


# Agents
# nix-config

- [ ] prefer plugins from https://github.com/NixNeovim/NixNeovimPlugins

- [ ] nix-config - don't commit?

# Systems

- server with 1 GB ethernet
- server github action runner

- boot server without external drives connected

- nextcloud
- nextcloud outside house
- nextcloud S3 backup


- home server nix cachce
- cron nix flake update and build. user notification to switch on each system.

- [ ] plex outside house





