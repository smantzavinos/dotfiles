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
      url = "github:smantzavinos/aider_flake/4f33ab9dc3ca2148b3128e6a3b5b117aa1586b6f";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      flags = {
        enableEpicGames = false;
        enableNextCloudServer = false;
        enableOneDrive = false;
        enableSteam = false;
        enableDevTools = false;
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableDevTools = false;
              };

              sharedModule = import ./system_shared.nix { inherit pkgs; flags = overriddenFlags; };
            in [
              sharedModule
              /etc/nixos/configuration.nix
              # /etc/nixos/hardware-configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = attrs // { flags = overriddenFlags; };
              }
              # (import ./system_shared.nix { inherit pkgs flags; })
              # sharedModule = import ./system_shared.nix { inherit pkgs; flags = overriddenFlags; };
              # ./systems/precision_t5600.nix
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

              sharedModule = import ./system_shared.nix {
                inherit pkgs;
                flags = overriddenFlags;
              };
            in [
              sharedModule
              /etc/nixos/configuration.nix
              /etc/nixos/hardware-configuration.nix
              ./systems/lenovo_x1_extreme.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = attrs // { flags = overriddenFlags; };
              }
            ];
        };

        t5600 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableEpicGames = true;
                enableOneDrive = true;
                enableSteam = true;
                enableDevTools = true;
              };

              sharedModule = import ./system_shared.nix {
                inherit pkgs;
                flags = overriddenFlags;
              };
            in [
              sharedModule
              /etc/nixos/configuration.nix
              /etc/nixos/hardware-configuration.nix
              ./systems/precision_t5600.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = attrs // { flags = overriddenFlags; };
              }
            ];
        };

        msi_gs66 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enablePlexServer = true;
              };

              sharedModule = import ./system_shared.nix {
                inherit pkgs;
                flags = overriddenFlags;
              };
            in [
              sharedModule
              ./systems/msi_gs66.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = attrs // { flags = overriddenFlags; };
              }
            ];
        };

        vbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableDevTools = true;
              };

              sharedModule = import ./system_shared.nix {
                inherit pkgs;
                flags = overriddenFlags;
              };
            in [
              sharedModule
              # TODO: Replace with local
              /etc/nixos/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.spiros = import ./home/home.nix;
                home-manager.extraSpecialArgs = attrs // { flags = overriddenFlags; };
              }
            ];
        };
      };
    };
}
