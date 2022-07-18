# dotfiles

## tmux
Create symlink to tmux config
```
cd ~
ln -s dotfiles/.tmux.conf .tmux.conf
```
Reload new config file (ctrl-b is default tmux prefix)
```
:source-file ~/.tmux.conf
```

## fish
Symlink to fish config and the plugins
```
cd ~
ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/fish/fish_plugins ~/.config/fish/fish_plugins
```
NOTE: Not using the full path can fail to create the correct symlink. It is therefore important to use the "~/" at the start of the path in the ln command. This gets expanded by the shell to the full path.

Load new fish config with:
```
source ~/.config/fish/config.fish
```

Install (fisher plugin)[https://github.com/jorgebucaran/fisher]. Run fisher update to install plugins listed in fish_plugins.
```
fisher update
```

## emacs
### windows

Link emacs config file. Run the following from the home directory.
```
mkdir .emacs.d
mklink /H .emacs.d\init.el dotfiles\.emacs.d\init.el
```

Also need to make sure that the `HOME` environment variable is set to `C:\Users\<user_name>`.

Change the start directory by setting it in the properties of the exe file.

### linux (ubuntu)

Link emacs config file. Run the following from the home directory.
```
ln -sd dotfiles/.emacs.d .emacs.d
```
