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
    };
}
