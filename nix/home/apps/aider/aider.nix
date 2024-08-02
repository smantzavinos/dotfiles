# { config, lib, pkgs, ... }:

# let
#   poetry2nix = pkgs.callPackage (pkgs.fetchFromGitHub {
#     owner = "nix-community";
#     repo = "poetry2nix";
#     rev = "2024.7.3185952"; # Check for the latest release
#     sha256 = "0rp7h5kc8pqkpjwfsmfg7n1h2l8j9lymdki86gxq2mjbpnkgdn67"; # Replace with the correct sha256
#   }) {};
# in
# {
#   # home.packages = lib.mkIf config.aider.enable [
#   #   (poetry2nix.mkPoetryEnv {
#   #     projectDir = "${config.aider.projectDir}";
#   #   })
#   # ];

#   home.packages = lib.mkIf config.aider.enable [
#     (poetry2nix.mkPoetryEnv {
#       projectDir = config.aider.projectDir;
#     })
#   ];
# }

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.aider;
in {
  options.programs.aider = {
    enable = mkEnableOption "aider";
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./aider-package.nix {};
      defaultText = literalExpression "pkgs.callPackage ./aider-package.nix {}";
      description = "The aider package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
