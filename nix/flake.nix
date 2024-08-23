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
      url = "github:smantzavinos/aider_flake/7e250ffac1caa357e9f3386d74cb736093dc09b4";
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
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            /etc/nixos/configuration.nix
            # /etc/nixos/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.spiros = import ./home/home.nix;
              home-manager.extraSpecialArgs = attrs // { inherit flags; };
            }
            ./system_shared.nix
            # ./systems/precision_t5600.nix
          ];
        };

        msi_gs66 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              overriddenFlags = flags // {
                enableEpicGames = false;
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
                home-manager.extraSpecialArgs = attrs // { inherit flags; };
              }
            ];
        };
      };
    };
}
