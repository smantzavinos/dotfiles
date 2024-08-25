{config, pkgs, aider-flake, whisper-input, flags, ...}:

{
    home.username = "spiros";
    home.homeDirectory = "/home/spiros";
    home.stateVersion = "23.11"; # To figure this out you can comment out the line and see what version it expected.
    programs.home-manager.enable = true;

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
    };

    imports = [
      # Note: Test on new system to confirm relative path does not cause issues
      # apps/s3drive/s3drive.nix
      /home/spiros/dotfiles/nix/home/apps/s3drive/s3drive.nix
    ];


    home.packages = let
      basePackages = [
        # utils
        pkgs.cowsay
        pkgs.gh
        pkgs.fd
        pkgs.ripgrep
        pkgs.lshw
        pkgs.fzf
        pkgs.nix-prefetch-github
        pkgs.jq
        pkgs.glxinfo
        pkgs.pciutils
        pkgs.dpkg
        pkgs.tree
        pkgs.aichat
        pkgs.degit
        pkgs.htop-vim
        pkgs.wireshark

        # zsh
        pkgs.zsh-powerlevel10k
        pkgs.zplug
        pkgs.oh-my-zsh
        pkgs.fzf-zsh

        # apps
        pkgs.google-chrome
        pkgs.libreoffice
        pkgs.drawio
        pkgs.nextcloud-client

        # fonts
        pkgs.nerdfonts
        pkgs.font-awesome
        pkgs.emacs-all-the-icons-fonts
        pkgs.material-icons
        pkgs.weather-icons

        # flakes passed in from top level flake.nix
        aider-flake.packages.x86_64-linux.default
        whisper-input.defaultPackage.x86_64-linux
      ];

      epicGamesPackages = if flags.enableEpicGames then [
        pkgs.lutris
        pkgs.wineWowPackages.full
      ] else [];

      oneDrivePackages = if flags.enableOneDrive then [
        pkgs.onedrive
        pkgs.onedrivegui
        pkgs.cryptomator
      ] else [];

      plexServerPackages = if flags.enablePlexCloudServer then [
        pkgs.libhdhomerun
        pkgs.hdhomerun-config-gui
      ] else [];

      nextCloudServerPackages = if flags.enableNextCloudServer then [
        pkgs.nextcloud29
      ] else [];
    in
      basePackages ++ 
      epicGamesPackages ++ 
      oneDrivePackages ++ 
      nextCloudServerPackages;

    # auto reload fonts so you don't need to execute `fc-cache -f -v` manually after install
    fonts.fontconfig.enable = true;

    programs.git = {
      enable = true;
      userName = "Spiros Mantzavinos";
      userEmail = "smantzavinos@gmail.com";
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraLuaConfig = ''
        vim.wo.number = true

        vim.api.nvim_set_keymap('n', '<C-m>', ':tabnext<CR>',
        {noremap = true, silent = true})
        vim.api.nvim_set_keymap('n', '<C-n>', ':tabprevious<CR>',
        {noremap = true, silent = true})
      '';
      plugins = [
        {
          plugin = pkgs.vimPlugins.neovim-ayu;
          type = "lua";
          config = ''
            vim.opt.termguicolors = true
            require('ayu').setup({
                mirage = true,
            })
            require('ayu').colorscheme()
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-web-devicons;
          type = "lua";
          config = ''
            require'nvim-web-devicons'.setup {
              -- globally enable "strict" selection of icons - icon will be looked up in
              -- different tables, first by filename, and if not found by extension; this
              -- prevents cases when file doesn't have any extension but still gets some icon
              -- because its name happened to match some extension (default to false)
              strict = true;
              -- same as `override` but specifically for overrides by filename
              -- takes effect when `strict` is true
              override_by_filename = {
               [".gitignore"] = {
                 icon = "",
                 color = "#f1502f",
                 name = "Gitignore"
               }
              };
              -- same as `override` but specifically for overrides by extension
              -- takes effect when `strict` is true
              override_by_extension = {
               ["log"] = {
                 icon = "",
                 color = "#81e043",
                 name = "Log"
               }
              };
            }
            -- Web Devicons wrapper. Called from startify config.
            function _G.webDevIcons(path)
              local filename = vim.fn.fnamemodify(path, ':t')
              local extension = vim.fn.fnamemodify(path, ':e')
              return require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
            end
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-startify;
          config = ''
            function! StartifyEntryFormat() abort
              return 'v:lua.webDevIcons(absolute_path) . " " . entry_path'
            endfunction
          '';
        }
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.indentLine
        {
          plugin = pkgs.vimPlugins.nvim-surround;
          type = "lua";
          config = ''
            require('nvim-surround').setup()
          '';
        }

        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup({
              options = {
                theme = 'ayu_mirage',
              },
            })
            vim.opt.showmode = false
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-tmux-navigator;
        }
      ];
    };

    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
      extraConfig = ''
        (load-file "/home/spiros/dotfiles/.emacs.d/init_local.el")
      '';
    };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Use Zplug for plugin management
    initExtraBeforeCompInit = ''
      source ${pkgs.zplug}/share/zplug/init.zsh

      # Load Powerlevel10k theme
      zplug "romkatv/powerlevel10k", as:theme, depth:1

      # source ${pkgs.zplug}/share/zplug/init.zsh

      # Load the Zplug plugins
      zplug "plugins/git", from:oh-my-zsh
      zplug "plugins/tmux", from:oh-my-zsh
      zplug "asdf-vm/asdf", use:"asdf.plugin.zsh"
      zplug "junegunn/fzf", as:command, use:"bin/*", hook-build:"./install --bin"
      zplug "Aloxaf/fzf-tab", defer:2
      zplug "zsh-users/zsh-autosuggestions", defer:2
      zplug "chitoku-k/fzf-zsh-completions", defer:2

      # Install plugins if there are plugins that have not been installed yet
      if ! zplug check --verbose; then
          printf "Install? [y/N]: "
          if read -q; then
              echo; zplug install
          fi
      fi

      # Load plugins and themes
      zplug load
    '';

    # Source the Powerlevel10k configuration if it exists
    initExtra = ''
      [[ ! -f ${"~/dotfiles/zsh/.p10k.zsh"} ]] || source ${"~/dotfiles/zsh/.p10k.zsh"}

      # <C-backspace> binding
      bindkey '^H' backward-kill-word

      # <C-f> binding to complete a word in the auto suggestion
      bindkey '^F' forward-word
    '';
  };

  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    shortcut = "a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    mouse = true;
    escapeTime = 20;
    keyMode = "vi";
    extraConfig = ''
        # ensure correct 256 color support in each term type
        set -g default-terminal "tmux-256color"
        set-option -ga terminal-overrides ",alacritty:Tc"
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set-option -ga terminal-overrides ",tmux-256color:Tc"

        # # VI keys for movement, selection, and copying
        # setw -g mode-keys vi
        # bind-key -T copy-mode-vi v send -X begin-selection
        # bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

        # # Don't rename windows automatically
        # set-option -g allow-rename off

        # # Restore neovim sessions when restoring tmux sessions
        # set -g @resurrect-strategy-nvim 'session'

        # # Restore pane contents when restoring tmux sessions
        # set -g @resurrect-capture-pane-contents 'on'
    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = dracula;
        extraConfig = ''
            set -g @dracula-show-battery true
            set -g @dracula-show-powerline true
            set -g @dracula-refresh-rate 10
            set -g @dracula-show-left-icon session

            set -g @dracula-plugins "weather cpu-usage ram-usage battery"
            set -g @dracula-cpu-usage-colors "yellow dark_gray"
            set -g @dracula-cpu-usage-label "\uf4bc"
            set -g @dracula-ram-usage-label "\ue266"
            set -g @dracula-show-location false
        '';
      }
      {
        plugin = tmux-fzf;
      }
      {
        plugin = vim-tmux-navigator;
      }
    ];
  };

  programs.kitty = {
    enable = true;
    theme = "Dracula";
    # font = "JetBrainsMono Nerd Font";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-c" "tmux attach || tmux new" ];
      };
      font = {
        size = 10.0;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };
    };
  };

}
