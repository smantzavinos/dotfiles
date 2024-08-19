{
    description = "My Home Manager Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {nixpkgs, home-manager, ...}: {
        # For `nix run .` later
        defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

        # System configuration
        # nixosConfigurations = {
        #     my-system = nixpkgs.lib.nixosSystem {
        #         system = "x86_64-linux";
        #         modules = [ ./system.nix ];
        #     };
        # };

        # Home configuration
        homeConfigurations = {
            "spiros" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                pkgs = import nixpkgs { system = "x86_64-linux"; };

                modules = [ ./home.nix ];
                home.username = "spiros";
                home.homeDirectory = "/home/spiros";
                home.stateVersion = "23.11"; 
            };
        };
    };
}

