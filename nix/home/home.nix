{ config
, lib
, pkgs
, pkgs_unstable
, aider-flake
, avante-nvim-nightly-flake
, buffrs
, whisper-input
, flags
, nixneovimplugins
, awesome-neovim-plugins
, ...
}:

{
    home.username = "spiros";
    home.homeDirectory = "/home/spiros";
    home.stateVersion = "24.11"; # To figure this out you can comment out the line and see what version it expected.
    programs.home-manager.enable = true;

    home.sessionVariables.EDITOR = "vim";

    # Allow unfree packages
    nixpkgs.config = {
        allowUnfree = true;
    };

    imports = [
      # Note: Test on new system to confirm relative path does not cause issues
      ./apps/s3drive/s3drive.nix
      ./modules/dictation.nix
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
        pkgs.yq-go
        pkgs.glxinfo
        pkgs.pciutils
        pkgs.dpkg
        pkgs.tree
        pkgs.aichat
        pkgs.degit
        pkgs.htop-vim
        pkgs.wireshark
        pkgs.age
        pkgs.ssh-to-age
        pkgs.sops
        pkgs.vlc
        pkgs.ncdu
        pkgs.nixd
        pkgs.nixfmt
        pkgs.usbutils
        pkgs.zoxide
        pkgs.pandoc
        pkgs.nix-direnv
        
        # C compiler and build tools for Treesitter parsers
        pkgs.gcc
        # Required for TreeSitter parser compilation
        pkgs.gnumake

        pkgs.sesh

        # zsh
        pkgs.starship
        pkgs.zplug
        pkgs.oh-my-zsh
        pkgs.fzf-zsh

        # apps
        pkgs.google-chrome
        pkgs.firefox
        pkgs.libreoffice
        pkgs.drawio
        pkgs.nextcloud-client
        pkgs.qbittorrent
        pkgs.obsidian

        # Note: fonts moved to system_shared.nix

        # flakes passed in from top level flake.nix
        whisper-input.defaultPackage.x86_64-linux
      ];

      devToolPackages = if flags.enableDevTools then [
        pkgs.nodejs_22
        pkgs.bun
        pkgs.plandex
        pkgs.plandex-server
        # pkgs.aider-chat
        pkgs_unstable.aider-chat-with-playwright
        # aider-flake.packages.x86_64-linux.default
        pkgs.tree-sitter
        pkgs.typescript-language-server
        pkgs.svelte-language-server
        pkgs.tailwindcss-language-server
        pkgs.lua-language-server
        pkgs_unstable.supabase-cli
        # pkgs_unstable.claude-code
        pkgs_unstable.opencode
        pkgs.python313
        pkgs.uv
        pkgs.mkcert

        buffrs.packages.x86_64-linux.default
      ] else [];

      localLLMPackages = if flags.enableLocalLLM then [
        pkgs.lmstudio
      ] else [];

      openWebUIPackages = if flags.enableOpenWebUI then [
        pkgs_unstable.open-webui
      ] else [];

      epicGamesPackages = if flags.enableEpicGames then [
        pkgs.lutris
        pkgs.wineWowPackages.full
      ] else [];

      oneDrivePackages = if flags.enableOneDrive then [
        pkgs.onedrive
        pkgs.onedrivegui
        pkgs.cryptomator
      ] else [];

      plexServerPackages = if flags.enablePlexServer then [
        pkgs.libhdhomerun
        pkgs.hdhomerun-config-gui
      ] else [];

      nextCloudServerPackages = if flags.enableNextCloudServer then [
        pkgs.nextcloud29
      ] else [];
    in
      basePackages ++ 
      devToolPackages ++
      localLLMPackages ++
      openWebUIPackages ++
      epicGamesPackages ++
      oneDrivePackages ++
      plexServerPackages ++
      nextCloudServerPackages;

    home.file.".aider-openai.yml" = {
      text = ''
        model: gpt-4o
        editor-model: gpt-4o-mini
        weak-model: gpt-3.5-turbo
      '';
    };

    home.file.".aider-gemini.yml" = {
      text = ''
        model: gemini            # alias → gemini/gemini-2.5-pro-latest or gemini/gemini-1.5-pro-preview-0514
        editor-model: flash      # alias → gemini/gemini-2.5-flash-latest or gemini/gemini-1.5-flash-preview-0514
        weak-model: flash        # cheap, low-latency fallback
      '';
    };

    home.file.".aider.conf.yml" = {
      text = builtins.readFile ./apps/aider/.aider.conf.yml;
    };

    home.file.".aider.model.settings.yml" = {
      text = builtins.readFile ./apps/aider/.aider.model.settings.yml;
    };

    # auto reload fonts so you don't need to execute `fc-cache -f -v` manually after install
    fonts.fontconfig.enable = true;


    home.shellAliases = {
      # Decrypts and loads API keys from a SOPS-encrypted YAML file into
      # environment variables, making them available for the current session.
      source_api_keys = ''
        eval "$(sops -d /home/spiros/dotfiles/nix/secrets/ai-api-keys.sops.yaml | yq eval -r '. | to_entries | .[] | "export \(.key)=\(.value)"')"
      '';

      # Sets up PostgreSQL-related environment variables for plandex server
      setup_plandex_server = ''
        export DB_HOST="localhost"
        export DB_PORT="5432"
        export DB_USER="postgres"
        export DB_PASSWORD="postgres"
        export DB_NAME="plandex"
        export DATABASE_URL="postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"

        export GOENV=development

        source_api_keys

        echo "PostgreSQL environment variables and API keys have been exported."
      '';

      # Aider configuration aliases
      aider-openai = "AIDER_CONFIG=$HOME/.aider-openai.yml aider \"$@\"";
      aider-gemini = "AIDER_CONFIG=$HOME/.aider-gemini.yml aider \"$@\"";
    };

    programs.git = {
      enable = true;
      userName = "Spiros Mantzavinos";
      userEmail = "smantzavinos@gmail.com";
      lfs.enable = true;
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        # GitHub configurations
        "github.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
        "github-globus" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519_globus";
          identitiesOnly = true;
        };
        
        # Local system configurations
        "nixos" = {
          hostname = "nixos.local";
          user = "spiros";
        };
        "x1" = {
          hostname = "x1.local";
          user = "spiros";
        };
        "t5600" = {
          hostname = "t5600.local";
          user = "spiros";
        };
        "t7910" = {
          hostname = "t7910.local";
          user = "spiros";
        };
        "msi_gs66" = {
          hostname = "msi_gs66.local";
          user = "spiros";
        };
        "msi_ms16" = {
          hostname = "msi_ms16.local";
          user = "spiros";
        };
        "vbox" = {
          hostname = "vbox.local";
          user = "spiros";
        };
      };
    };

    programs.starship = {
      enable = true;
    };

    home.file.".config/starship.toml" = {
      text = builtins.readFile ./starship.toml;
    };

    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true; # see note on other shells below
        nix-direnv.enable = true;
      };
    };

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
        svelte.svelte-vscode
      ];
    };

    xdg.configFile."nvim/lua/plugins" = if flags.enableDevMode then {
      # In dev mode, create symlinks to the source files for rapid iteration
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nix/home/nvim/lua";
    } else {
      # In normal mode, copy files to nix store
      recursive = true;
      source = ./nvim/lua;
    };

    programs.neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraLuaConfig = ''
        vim.g.mapleader = "\\" -- Set leader key to backslash
        require("lazy").setup({
          performance = {
            reset_packpath = false,
            rtp = {
                reset = false,
              }
            },
          dev = {
            path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
            patterns = {""},
          },
          install = {
            -- Safeguard in case we forget to install a plugin with Nix
            missing = false,
          },
          spec = {
            { import = "plugins" },
            -- Add other plugins here
          }
        })





        vim.wo.number = true

        vim.api.nvim_set_keymap('n', '<C-m>', ':tabnext<CR>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap('n', '<C-n>', ':tabprevious<CR>', {noremap = true, silent = true})

        vim.api.nvim_set_keymap('n', 'Y', 'yy', { noremap = true, silent = true })



        -- Replace tabs with spaces
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true

        -- Enable autoread and set up autocommand for auto-reloading buffers
        vim.opt.autoread = true
        vim.api.nvim_create_autocmd({"FocusGained", "BufEnter", "CursorHold", "CursorHoldI"}, {
          command = "checktime"
        })

        -- Add keybinding to show diagnostics in a floating window
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { noremap = true, silent = true })

        vim.keymap.set("n", "<leader>id", function()
          vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
        end, { desc = "Insert date" })
        
        -- Add keybinding to copy all diagnostics to clipboard
        vim.keymap.set('n', '<leader>D', function()
          local diagnostics = vim.diagnostic.get(0)
          local lines = {}
          for _, d in ipairs(diagnostics) do
            table.insert(lines, string.format("[%s] %s (line %d)", d.severity, d.message, d.lnum + 1))
          end
          local text = table.concat(lines, '\n')
          vim.fn.setreg('+', text) -- Copy to system clipboard
          print("Diagnostics copied to clipboard")
        end, { noremap = true, silent = true })

        -- Keymaps and settings for Markdown / Obsidian
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function()
            local map = function(mode, lhs, rhs, opts)
              opts = opts or {}
              opts.buffer = true
              vim.keymap.set(mode, lhs, rhs, opts)
            end

            -- Function to cycle bullet points
            local function cycle_bullet()
              local line = vim.api.nvim_get_current_line()
              local bullets = { "-", "*", "+" }
              local new_line, found = line:gsub(
                "^%s*([%-%*%+])", -- Match leading whitespace and one of the bullet characters
                function(bullet)
                  for i, b in ipairs(bullets) do
                    if b == bullet then
                      -- Cycle to the next bullet
                      local next_bullet_index = (i % #bullets) + 1
                      return bullets[next_bullet_index]
                    end
                  end
                end,
                1 -- Only replace the first occurrence
              )
              if found > 0 then
                vim.api.nvim_set_current_line(new_line)
              end
            end

            -- Cycle checkbox states for obsidian.nvim
            map("n", "<leader>x", "<cmd>ObsidianCycleCheckbox<CR>", { silent = true, desc = "Cycle Checkbox" })

            -- Create new list items
            map("n", "<S-CR>", "o[ ] <Esc>", { silent = true, desc = "New TODO Item" })

            -- Cycle bullet type
            map("n", "<C-t>", cycle_bullet, { silent = true, desc = "Cycle Bullet Type" })
            
            -- keep indentation but turn off automatic list / comment continuation
            vim.opt_local.autoindent = true
            vim.opt_local.formatoptions:remove({ "r", "o", "n" })
          end,
        })
      '';
      plugins = let
        # Custom opencode.nvim plugin since it's not in nixpkgs yet
        opencode-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "opencode-nvim";
          version = "2025-01-22";
          src = pkgs.fetchFromGitHub {
            owner = "NickvanDyke";
            repo = "opencode.nvim";
            rev = "5925ad49f01f24bcffea55934cad20c3b4d2d262";
            sha256 = "sha256-srW7IFrmO6KuK0rVsxg0j+X5e+EMuE9R8XkCXXVdhWE=";
          };
          meta = with pkgs.lib; {
            description = "Seamlessly integrate the opencode AI assistant with Neovim";
            homepage = "https://github.com/NickvanDyke/opencode.nvim";
            license = licenses.mit;
            maintainers = [];
          };
        };

        # Custom possession.nvim plugin since it's not in nixpkgs yet
        possession-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "possession-nvim";
          version = "2025-01-24";
          src = pkgs.fetchFromGitHub {
            owner = "jedrzejboczar";
            repo = "possession.nvim";
            rev = "7e0abb58ccf1e7c03d9c80f9a2515ab9befb0d4d";
            sha256 = "1llg58h5kq3x19jgmlkkvbdkcjq615kchv6yi5ik2hnqcpwlgf4g";
          };
          meta = with pkgs.lib; {
            description = "Flexible session management for Neovim";
            homepage = "https://github.com/jedrzejboczar/possession.nvim";
            license = licenses.mit;
            maintainers = [];
          };
        };
      in [
        pkgs.vimPlugins.autolist-nvim
        pkgs.vimPlugins.mini-move
        pkgs.vimPlugins.dial-nvim
        pkgs.vimPlugins.img-clip-nvim
        pkgs.vimPlugins.render-markdown-nvim
        pkgs.vimPlugins.dressing-nvim
        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.nui-nvim
        pkgs_unstable.vimPlugins.blink-cmp-avante
        # Nightly flake wasn't working. Commands were mising.
        # avante-nvim-nightly-flake.packages.${pkgs.system}.default
        pkgs_unstable.vimPlugins.avante-nvim

        # pkgs_unstable.vimPlugins.codecompanion-nvim
        nixneovimplugins.packages.${pkgs.system}.codecompanion-nvim

        # Custom opencode.nvim plugin
        opencode-nvim

        # Custom possession.nvim plugin
        possession-nvim

        # Alpha.nvim for startup screen
        pkgs.vimPlugins.alpha-nvim

        pkgs.vimPlugins.lazy-nvim
        # Add required dependencies first
        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.nvim-cmp
        pkgs.vimPlugins.telescope-nvim
        # Now list obsidian.nvim after its dependencies
        pkgs.vimPlugins.obsidian-nvim
        pkgs.vimPlugins.nvim-tree-lua
        # {
        #   plugin = nixneovimplugins.packages.${pkgs.system}.codecompanion-nvim;
        #   type = "lua";
        #   config = ''
        #     require("codecompanion").setup({
        #       adapters = {
        #         anthropic = {
        #           api_key = os.getenv("ANTHROPIC_API_KEY")
        #         }
        #       },
        #       default_adapter = "anthropic",
        #       size = {
        #         width = "40%",
        #         height = "60%"
        #       },
        #     })
        #
        #     -- Key mappings for CodeCompanion
        #     vim.keymap.set('n', '<leader>cc', ':CodeCompanion<CR>', { noremap = true, silent = true })
        #     vim.keymap.set('v', '<leader>cc', ':CodeCompanion<CR>', { noremap = true, silent = true })
        #     vim.keymap.set('n', '<leader>cs', ':CodeCompanionToggle<CR>', { noremap = true, silent = true })
        #   '';
        # }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter;
          type = "lua";
          config = ''
            -- Set custom parser install location in writable path
            local parser_install_dir = vim.fn.stdpath("data") .. "/treesitter-parsers"
            vim.fn.mkdir(parser_install_dir, "p")  -- Create directory if it doesn't exist
            
            vim.opt.runtimepath:append(parser_install_dir)
            
            require("nvim-treesitter.configs").setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
              parser_install_dir = parser_install_dir,
              ensure_installed = {
                "svelte", 
                "typescript", 
                "html",
                "javascript",
                "json",
                "lua",
                "nix",
                "yaml",
              },
            })
          '';
        }
        pkgs.vimPlugins.fzf-lua
        pkgs.vimPlugins.neovim-ayu
        pkgs.vimPlugins.neogit
        pkgs.vimPlugins.diffview-nvim
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.nvim-dap
        pkgs.vimPlugins.nvim-dap-ui
        pkgs_unstable.vimPlugins.snacks-nvim
        pkgs.vimPlugins.which-key-nvim
        awesome-neovim-plugins.packages.${pkgs.system}.nvim-aider
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
        pkgs.vimPlugins.luasnip
        pkgs_unstable.vimPlugins.blink-cmp
        pkgs.vimPlugins.friendly-snippets
        pkgs.vimPlugins.nvim-lspconfig
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

      # Starship will be initialized in initExtra instead of using zplug theme

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

    # Initialize Starship prompt
    initExtra = ''
      eval "$(starship init zsh)"

      # <C-backspace> binding
      bindkey '^H' backward-kill-word

      # <C-f> binding to complete a word in the auto suggestion
      bindkey '^F' forward-word

      # zoxide completions in zsh
      eval "$(zoxide init zsh)"
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

        # Don't rename windows automatically
        set-option -g allow-rename off

        # Recommended binding for sesh using fzf-tmux
        bind-key "T" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""

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
      {
        plugin = resurrect;
        extraConfig = ''
          # Restore neovim sessions when restoring tmux sessions
          set -g @resurrect-strategy-nvim 'session'

          # Restore pane contents when restoring tmux sessions
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
    ];
  };

  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
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

  programs.lazygit = {
    enable = true;
    settings = {
      # this is not working for some reason
      keybinding.universal.commits.openLogMenu = "alt+l";
    };
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
    };
  };

    # Dictation configuration
    programs.dictation = {
      enable = true;
      useAPI = true;  # Enable fast API-based transcription
      apiProvider = "openai";  # Use OpenAI Whisper API (change to "groq" for free alternative)
      # Fallback local model (only used if useAPI = false)
      model.url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
      model.sha256 = "a03779c86df3323075f5e796cb2ce5029f00ec8869eee3fdfb897afe36c6d002";
      shortcuts.start = "Meta+V";
      shortcuts.stop = "Meta+Shift+V";
    };

    # Dev mode notification
    home.activation.devModeNotification = lib.mkIf flags.enableDevMode (lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "🚀 Dev Mode Active: Neovim configs are symlinked for rapid iteration"
      echo "   Config path: ~/.config/nvim/lua/plugins -> ~/dotfiles/nix/home/nvim/lua"
      echo "   Edit files directly in ~/dotfiles/nix/home/nvim/lua/ for instant changes"
    '');
}
