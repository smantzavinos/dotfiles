{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.s3drive;
in {
  options.programs.s3drive = {
    enable = mkEnableOption "s3drive";
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./s3drive-package.nix {};
      defaultText = literalExpression "pkgs.callPackage ./s3drive-package.nix {}";
      description = "The s3drive package to use.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Optional: Add desktop file
    xdg.desktopEntries.s3drive = {
      name = "S3Drive";
      exec = "${cfg.package}/bin/s3drive-wrapped";
      icon = "${cfg.package}/data/flutter_assets/assets/logos/logo_128.png";
      comment = "Zero Knowledge E2E encrypted storage compatible with any S3 provider";
      categories = [ "Utility" "FileManager" "Network" ];
    };
  };
}
