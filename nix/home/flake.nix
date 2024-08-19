{
    description = "My Home Manager Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        whisper-input = {
            url = "github:Quoteme/whisper-input/2ddac6100928297dab028446ef8dc9b17325b833";
        };
        aider-flake = {
            url = "github:smantzavinos/aider_flake/7e250ffac1caa357e9f3386d74cb736093dc09b4";
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

