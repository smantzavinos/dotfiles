# dotfiles

## tmux
Create symlink to tmux config
```
cd ~
ln -s dotfiles/.tmux.conf .tmux.conf
```

## fish
Symlink to fish config and the plugins
```
cd ~
ln -s dotfiles/fish/config.fish .config/fish/config.fish
ln -s dotfiles/fish/fish_plugins .config/fish/fish_plugins
```

Install (fisher plugin)[https://github.com/jorgebucaran/fisher]. Run fisher update to install plugins listed in fish_plugins.
```
fisher update
```
