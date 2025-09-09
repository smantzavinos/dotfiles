
# NixOS and Home Manager Configuration

## Overview
This repository contains my personal NixOS and Home Manager configurations.
System configuration is stored as single file that is imported in existing system configuration.
Home environment uses Nix Flakes to ensure reproducible builds and easy
management of system and user-level settings.

## Structure
- /system_shared.nix/: Contains the system-wide NixOS configuration.
- /home.nix/: Holds the user-specific configuration managed by Home Manager.
- /flake.nix/: The central flake file defining inputs and outputs for Home Manager.

### vim
Vim plugins are installed as nixpkgs. Lazy.nvim is used to load packages, but is configured to not auto-install any missing ones.

If there is a plugin that is not available in nixos, you can configure it with Lazy.nvim and install with `:Lazy install` in vim.

## Usage

### Prerequisites
- Nix with Flakes support enabled. See [[Appendix]] for details on setting up NixOS system.

### Install [Home Manager](https://nix-community.github.io/home-manager/index.html)
Run:
``` bash
cd ~/dotfiles/nix/home
nix build .#homeConfigurations.spiros.activationPackage
#+end_src

This will create the file `./result/activate` that can then be executed to install home-manager into the user environment. This is persistent across shells and system reboots.

Install home manager:
#+begin_src bash
./result/activate

```

### Free up disk space in NixOS

See list of system generations:
``` bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

See list of generations with size of each:
``` bash
for gen in $(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | awk '{print $1}'); do
  path=$(readlink -f /nix/var/nix/profiles/system-${gen}-link)
  size=$(nix path-info --closure-size "$path" | awk '{print $2}')
  echo "Generation $gen: $((size/1024/1024)) MB"
done
```

Keep only the 5 latest generations
``` bash
sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
```

Check size before and after deletign
``` bash
df -h /
```

Free up and nix store entries that are no longer referenced
``` bash
nix-collect-garbage
```


## Keyboard Shortcuts

### tmux

| Shortcut         | Description                                 |
|------------------|---------------------------------------------|
| `prefix` + `c`   | New window                                  |
| `prefix` + `,`   | Rename window                               |
| `prefix` + `n`   | Next window                                 |
| `prefix` + `p`   | Previous window                             |
| `prefix` + `%`   | Split pane vertically                       |
| `prefix` + `"`   | Split pane horizontally                     |
| `prefix` + `h/j/k/l` | Move between panes (vim-tmux-navigator) |
| `prefix` + `T`   | sesh session picker (fzf)                   |
| `prefix` + `[`   | Enter copy mode                             |
| `prefix` + `d`   | Detach session                              |

### zsh

| Shortcut         | Description                                 |
|------------------|---------------------------------------------|
| `<C-h>`          | Delete previous word                        |
| `<C-f>`          | Move forward one word                       |
| `source_api_keys`| Load API keys from SOPS-encrypted YAML      |
| `setup_plandex_server` | Set up PostgreSQL env vars for plandex |
| `aider-openai`   | Run aider with OpenAI config                |
| `aider-gemini`   | Run aider with Gemini config                |

### Dictation (KDE X11)

| Shortcut         | Description                                 |
|------------------|---------------------------------------------|
| `Meta+V`         | Start voice recording for dictation        |
| `Meta+Shift+V`   | Stop recording and type transcribed text   |

The dictation system uses whisper.cpp for speech-to-text transcription and types the result directly into the active window. See [README-dictation.md](README-dictation.md) for detailed setup and usage instructions.

### neovim

#### Git Workflow
The git integration provides a comprehensive workflow with multiple tools:

- **Git Status**: `<leader>gs` opens the main git interface
- **Diff Viewing**: `<leader>gd` shows detailed changes with diffview
- **File History**: `<leader>gh` (all files) or `<leader>gH` (current file)
- **Tree Integration**: `<leader>gt` for git status in tree view

#### Keybindings

| Action/Command                | Normal Mode      | Visual Mode      | Insert Mode      | Description                                         |
|-------------------------------|------------------|------------------|------------------|-----------------------------------------------------|
| Show diagnostics              | `<leader>d`      |                  |                  | Show diagnostics in floating window                 |
| Copy all diagnostics          | `<leader>D`      |                  |                  | Copy all diagnostics to clipboard                   |
| Insert current date           | `<leader>id`     |                  |                  | Insert current date                                 |
| Yank (copy) current line      | `Y`              |                  |                  |                                                     |
| Next tab                      | `<C-m>`          |                  |                  |                                                     |
| Previous tab                  | `<C-n>`          |                  |                  |                                                     |
| Open CodeCompanion            | `<leader>cc`     |                  |                  |                                                     |
| Toggle CodeCompanion          | `<leader>cs`     |                  |                  |                                                     |
| Toggle Aider                  | `<leader>a/`     |                  |                  |                                                     |
| Send to Aider                 | `<leader>as`     | `<leader>as`     |                  |                                                     |
| Open Neogit                   | `<leader>gs`     |                  |                  | Git status and operations interface                 |
| Open git diff view            | `<leader>gd`     |                  |                  | Show git changes with diffview                      |
| Close git diff view           | `<leader>gD`     |                  |                  | Close diffview                                       |
| Git file history              | `<leader>gh`     |                  |                  | Show git history for all files                      |
| Current file git history      | `<leader>gH`     |                  |                  | Show git history for current file                   |
| Refresh git diff view         | `<leader>gr`     |                  |                  | Refresh the diffview                                 |
| Toggle Neo-tree file explorer | `<leader>e`      |                  |                  | Open/close filesystem tree view                     |
| FZF: Find files               | `<C-p>`          |                  |                  |                                                     |
| FZF: List buffers             | `<C-b>`          |                  |                  |                                                     |
| FZF: Live grep                | `<C-g>`          |                  |                  |                                                     |
| Increment number/date         | `g+`             | `g+`             |                  | (dial.nvim) |
| Decrement number/date         | `g-`             | `g-`             |                  | (dial.nvim) |
| Move line/selection down      | `<M-j>`          | `<M-j>`          |                  | (mini.move)                                         |
| Move line/selection up        | `<M-k>`          | `<M-k>`          |                  | (mini.move)                                         |
| Move line/selection left      | `<M-h>`          | `<M-h>`          |                  | (mini.move)                                         |
| Move line/selection right     | `<M-l>`          | `<M-l>`          |                  | (mini.move)                                         |
| Cycle checkbox state          | `<leader>x`      |                  |                  | (Obsidian/Markdown)                                 |
| New TODO item                 | `<S-CR>`         |                  |                  | (Obsidian/Markdown)                                 |
| Cycle bullet type             | `<C-t>`          |                  |                  | (Obsidian/Markdown)                                 |

#### Obsidian/Markdown-specific

| Action                        | Normal Mode         | Visual Mode         | Insert Mode         | Description                                 |
|-------------------------------|---------------------|---------------------|---------------------|---------------------------------------------|
| **List**                      |                     |                     |                     |                                             |
| Add new item                  | `<M-CR>`            |                     |                     | Add new list item                           |
| Move item up/down             | `<M-j>` / `<M-k>`   | `<M-j>` / `<M-k>`   |                     | Move item up/down                           |
| Move item up/down with subtree| N/A                 | `<M-j>` / `<M-k>`   |                     |                                             |
| Fold item with subtree        |                     |                     |                     |                                             |
| **Headings**                  |                     |                     |                     |                                             |
| Indent/Outdent heading        |                     |                     |                     | TODO                                        |
| Add new heading below/above   |                     |                     |                     | TODO                                        |
| Fold heading                  | `zc` (on heading)   |                     |                     | Fold current heading                        |
| Fold all headings             | `zM`                |                     |                     | Fold all headings                           |
| Fold all child headings       |                     |                     |                     |                                             |
| **Other**                     |                     |                     |                     |                                             |
| Insert date                   | `<leader>id`        |                     |                     | Insert current date                         |
| Increase/decrease date        | `g+` / `g-`      | `g+` / `g-`      |                 | |

**Legend:**  
- `<leader>` is set to `\` (backslash)  
- `<M-...>` means "Alt/Meta + ..."  
- `<C-...>` means "Ctrl + ..."  
- `<S-CR>` means "Shift + Enter"  
- `zM`, `zc` are standard Vim fold commands

---

*For more, see the plugin documentation or your `extraLuaConfig` in `home.nix`.*

### Applying Home Manager Configuration
To apply the Home Manager configuration for the user 'spiros', use:
``` bash
home-manager switch --flake .
```

### Clone dotfiles
Can now use GitHub CLI to clone dotfile repos
``` bash
cd ~
gh repo auth login
gh repo clone dotfiles
gh repo clone vimfiles
```
## Appendix
### Setting up NixOS
#### Update NixOS version
See the [NixOS Upgrade Instructions](https://nixos.org/manual/nixos/stable/index.html#sec-upgrading)

Basic steps are:

See what channel you are currently on
``` bash
sudo nix-channel --list | grep nixos
```

Update the channel
``` bash
sudo nix-channel --add https://channels.nixos.org/nixos-23.11 nixos
```

Upgrade with
``` bash
# option 1
sudo nixos-rebuild switch --upgrade

# option 2 (equivalent to option 1)
sudo nix-channel --update nixos
sudo nixos-rebuild switch
```

#### Install git and vim
Edit config to install git and vim.
``` bash
sudo nano /etc/nixos/configuration.nix
```

Install git as shown below
``` bash
users.users.spiros = {
  ...
  packages = with pkgs; [
     ...
    git  # Add this line <------
    ...
  ];
};
```

Run the following command to install git
``` bash
sudo nixos-rebuild switch
```

#### System shared config
clone the dotfiles_nix repo in the home directory.

Edit the system configuration file again to import the shared system configuration file:
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix # add this line <------
  ];
 ...
```
#### System specific config
If the system config also includes a system specific config, include that file as well.
##### Dell Precision T5600
Edit /etc/nixos/configuration.nix
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix
    /home/spiros/dotfiles/nix/systems/precision_t5600.nix # add this line <------
  ];
 ...
```
##### Lenovo X1 Extreme Gen 2
Set up the nixos-hardware channel
``` bash
$ sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
$ sudo nix-channel --update
```

Add [nixos-hardware](https://github.com/NixOS/nixos-hardware) config and system specific config.
The nixos-hardware config correctly installs things like battery settings, screen DPI settings, and trackpad drivers.
The system specific config also sets up nvidia drivers. I'm not sure why the nixos-hardware channel does not configure this. The nvidia drivers are set up for "sync mode". See the [NixOS Nvidia Wiki](https://nixos.wiki/wiki/Nvidia) for more information.
``` bash
...
imports =
  [
    ./hardware-configuration.nix
    /home/spiros/dotfiles/nix/system_shared.nix
    <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2> # add this line <------
    /home/spiros/dotfiles/nix/systems/lenovo_x1_extreme.nix # add this line <------
  ];
 ...
```

#### Apply system confg
and rebuild NixOS again
``` bash
sudo nixos-rebuild switch
```
#### Set up ssh keys
Copy ssh keys to the system. Either by USB or scp.

Ensure key file permission are restrictive enough (required by ssh agent)
``` bash
chmod 600 ~/.ssh/your_private_key
```

Load the key in to the agent
``` bash
ssh-add ~/.ssh/your_private_key
```

Now ready to follow instructions above to install home manager.
