{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    whisper-input = {
      url = "github:Quoteme/whisper-input/2ddac6100928297dab028446ef8dc9b17325b833";
    };
    aider-flake = {
      url = "github:smantzavinos/aider_flake/2b94bd46df49c5b3a1bd151a1e1e32aad65fbcaf";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      flags = {
        enableEpicGames = false;
        enableNextCloudServer = false;
        enablePlexServer = false;
        enableOneDrive = false;
        enableSteam = false;
        enableDevTools = false;
        enableLocalLLM = false;
      };
      # Add standardized home-manager config
      standardHomeManagerConfig = flags: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.spiros = import ./home/home.nix;
          extraSpecialArgs = inputs // { inherit flags; };
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
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                # TODO: can I remove this since I have specialArgs set?
                home-manager.extraSpecialArgs = inputs // { flags = overriddenFlags; };
              }
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
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = inputs // { flags = overriddenFlags; };
              }
            ];
        };

        msi_ms16 = let
          systemFlags = flags // {
            enableDevTools = true;
            enableLocalLLM = true;
          };
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flags = systemFlags; };
          modules = [
            ./system_shared.nix
            inputs.sops-nix.nixosModules.sops
            /etc/nixos/configuration.nix
            # ./systems/msi_ms16.nix
            home-manager.nixosModules.home-manager
            (standardHomeManagerConfig systemFlags)
          ];
        };

        vbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableDevTools = true;
              };

              specialArgs = { flags = flags // {
                enableOneDrive = true;
                enableDevTools = true;
              }; };

            in [
              ./system_shared.nix
              inputs.sops-nix.nixosModules.sops
              ./systems/virtualbox.nix
              # "${nixpkgs}/nixos/modules/installer/virtualbox-demo.nix"
              # "${nixpkgs}/nixos/modules/virtualisation/virtualbox-image.nix"
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = inputs // { flags = overriddenFlags; };
              }
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
