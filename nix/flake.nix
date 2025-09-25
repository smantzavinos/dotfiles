{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awesome-neovim-plugins = {
      url = "github:m15a/flake-awesome-neovim-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    whisper-input = {
      url = "github:Quoteme/whisper-input/2ddac6100928297dab028446ef8dc9b17325b833";
    };
    aider-flake = {
      url = "github:smantzavinos/aider_flake/65ab799e41d91de8ffecd86e07a841f1dd697d43";
    };
    avante-nvim-nightly-flake = {
      url = "github:vinnymeller/avante-nvim-nightly-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    buffrs.url = "github:helsing-ai/buffrs";
    nixneovimplugins = {
      url = "github:NixNeovim/NixNeovimPlugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, nixneovimplugins, awesome-neovim-plugins, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ awesome-neovim-plugins.overlays.default ];
      };
      pkgs_unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = pkgs.lib;
      flags = {
        enableEpicGames = false;
        enableNextCloudServer = false;
        enablePlexServer = false;
        enableOneDrive = false;
        enableSteam = false;
        enableDevTools = false;
        enableLocalLLM = false;
        enableOpenWebUI = false;
        enableDevMode = false;
      };
      # Shared home config generator
      mkHomeConfig = { system, username, pkgs, flags, inputs, pkgs_unstable, awesome-neovim-plugins }: rec {
        homeModule = {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${username} = import ./home/home.nix;
            extraSpecialArgs = inputs // { 
              inherit flags pkgs_unstable awesome-neovim-plugins; 
            };
          };
        };

        standaloneHomeConfig = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/home.nix ];
          extraSpecialArgs = inputs // { 
            inherit flags pkgs_unstable awesome-neovim-plugins; 
          };
        };
      };

      # System definitions with flags and modules
      systemDefs = {
        nixos = {
          flags = flags // {
            enableDevTools = false;
          };
          extraModules = [
            ./home/apps/litellm/litellm.nix
            /etc/nixos/configuration.nix
          ];
        };

        x1 = {
          flags = flags // {
            enableDevTools = true;
            enableDevMode = false;
          };
          extraModules = [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
            ./systems/lenovo_x1_extreme.nix
            /etc/nixos/configuration.nix
          ];
        };

        t5600 = {
          flags = flags // {
            enableEpicGames = true;
            enableSteam = true;
            enableDevTools = true;
            enablePlexServer = true;
            enableLocalLLM = true;
            enableDevMode = false;
          };
          extraModules = [
            ./systems/precision_t5600.nix
          ];
        };

        t7910 = {
          flags = flags // {
            enableSteam = true;
            enableDevTools = true;
            enableLocalLLM = true;
          };
          extraModules = [
            ./systems/precision_t7910.nix
          ];
        };

        msi_gs66 = {
          flags = flags // {
            enablePlexServer = true;
            enableDevTools = true;
          };
          extraModules = [
            ./systems/msi_gs66.nix
          ];
        };

        msi_ms16 = {
          flags = flags // {
            enableDevTools = true;
            enableLocalLLM = true;
            enableOpenWebUI = false;
            enableDevMode = false;
          };
          extraModules = [
            ./home/apps/litellm/litellm.nix
            /etc/nixos/configuration.nix
          ];
        };

        vbox = {
          flags = flags // {
            enableDevTools = true;
          };
          extraModules = [
            ./systems/virtualbox.nix
          ];
        };
      };

      # Generate home configs for all systems
      homes = builtins.mapAttrs
        (name: cfg:
           mkHomeConfig {
             inherit system pkgs inputs pkgs_unstable awesome-neovim-plugins;
             username = "spiros";
             flags = cfg.flags;
           })
        systemDefs;
    in
    {
      # Generate nixosConfigurations using systemDefs
      nixosConfigurations = builtins.mapAttrs
        (name: cfg:
          nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { flags = cfg.flags; };
            modules = [
              ./system_shared.nix
              inputs.sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
              homes.${name}.homeModule
            ] ++ cfg.extraModules;
          })
        systemDefs // {
        # Special case for installMedia
        installMedia = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            home-manager.nixosModules.home-manager
            (mkHomeConfig {
              inherit system pkgs inputs pkgs_unstable awesome-neovim-plugins;
              username = "spiros";
              flags = flags;
            }).homeModule
            {
              isoImage.squashfsCompression = "gzip -Xcompression-level 1";
              home-manager.users.spiros.home.homeDirectory = lib.mkForce "/home/spiros";
            }
          ];
        };
      };

      # Generate standalone homeConfigurations
      homeConfigurations = builtins.mapAttrs
        (name: _: homes.${name}.standaloneHomeConfig)
        systemDefs;
    };
}
