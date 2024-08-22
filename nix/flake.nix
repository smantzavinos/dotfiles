# {
#   description = "NixOS configuration for Spiros' system";

#   # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

#   outputs = { self, nixpkgs, home-manager, ... }@inputs:
#     let
#       system = "x86_64-linux";
#       overlays = import ./overlays.nix;
#       pkgs = import nixpkgs {
#         inherit system;
#         overlays = [ overlays ];
#       };
#     in
#     {
#       nixosConfigurations = {
#         hostname = pkgs.lib.nixosSystem {
#           system = "x86_64-linux";
#           modules = [
#             /etc/nixos/configuration.nix
#             /etc/nixos/hardware-configuration.nix
#             # ./home/spiros/dotfiles/system_shared.nix
#             # ./home/spiros/dotfiles/systems/precision_t5600.nix
#             ./system_shared.nix
#             ./systems/precision_t5600.nix
#           ];
#         };
#       };
#     };
# }

{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-flake = {
      url = "path:/path/to/your/home-manager-flake"; # Adjust the path to your home-manager flake
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
        enableEpicGames = false; # Set this to false to disable Epic Games by default
        enableNextCloudServer = false; # Set this to false to disable NextCloud Server by default
        enableOneDrive = false; # Set this to false to disable OneDrive, OneDrive GUI, and cryptomator
      };
    in
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          /etc/nixos/configuration.nix
          /etc/nixos/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.spiros = home-manager-flake.homeConfigurations."spiros".activationPackage;
            home-manager.extraSpecialArgs = attrs // { inherit flags; };
          }
          ./system_shared.nix
          # ./systems/precision_t5600.nix
        ];
      };
    };
}
