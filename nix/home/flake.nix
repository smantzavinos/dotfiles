{
  description = "My Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = { self, nixpkgs, home-manager, whisper-input, aider-flake, ... }@attrs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # For `nix run .` later
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

      # Home configuration
      homeConfigurations = {
        "spiros" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [ ./home.nix ];
          specialArgs = { inherit whisper-input aider-flake; };
        };
      };
    };
}

                modules = [ ./home.nix ];
            };
        };
    };
}

