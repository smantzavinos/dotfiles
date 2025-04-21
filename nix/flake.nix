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

  outputs = { self, nixpkgs, home-manager, nixos-hardware, nixneovimplugins, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
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
      };
      # Add standardized home-manager config
      standardHomeManagerConfig = flags: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.spiros = import ./home/home.nix;
          extraSpecialArgs = inputs // { 
            inherit flags pkgs_unstable; 
          };
        };
      };
    in
    {
      nixosConfigurations = {
        nixos = let
          systemFlags = flags // {
            enableDevTools = false;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            ./systems/litellm-docker.nix
            inputs.sops-nix.nixosModules.sops
            /etc/nixos/configuration.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        x1 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableOneDrive = true;
                enableDevTools = true;
              };

              # modify flags that are passed to improted modules
              specialArgs = { flags = flags // {
                enableOneDrive = true;
                enableDevTools = true;
                enablePlexServer = true;
              }; };

            in [
              ./system_shared.nix
              inputs.sops-nix.nixosModules.sops
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
              ./systems/lenovo_x1_extreme.nix
              (standardHomeManagerConfig (flags // {
                enableOneDrive = true;
                enableDevTools  = true;
                enablePlexServer = true;
              }))
            ];
        };

        t5600 = let
          systemFlags = flags // {
            enableEpicGames = true;
            enableSteam = true;
            enableDevTools = true;
            enablePlexServer = true;
            enableLocalLLM = true;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            ./systems/precision_t5600.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        t7910 = let
          systemFlags = flags // {
            enableEpicGames = true;
            enableSteam = true;
            enableDevTools = true;
            enableLocalLLM = true;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            ./systems/precision_t7910.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        msi_gs66 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enablePlexServer = true;
              };

            in [
              ./system_shared.nix
              inputs.sops-nix.nixosModules.sops
              ./systems/msi_gs66.nix
              (standardHomeManagerConfig (flags // { enablePlexServer = true; }))
            ];
        };

        msi_ms16 = let
          systemFlags = flags // {
            enableDevTools = true;
            enableLocalLLM = true;
            enableOpenWebUI = false;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            ./home/apps/litellm/litellm.nix
            inputs.sops-nix.nixosModules.sops
            /etc/nixos/configuration.nix
            # ./systems/msi_ms16.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        vbox = let
          systemFlags = flags // {
            enableDevTools = true;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            ./systems/virtualbox.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        # Not working
        installMedia = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig flags)
            {
              isoImage.squashfsCompression = "gzip -Xcompression-level 1";
              home-manager.users.spiros.home.homeDirectory = lib.mkForce "/home/spiros";
            }
          ];
        };
      };
    };
}
