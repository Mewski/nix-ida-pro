{ self, ... }:
{ config, lib, ... }:
let
  cfg = config.programs.ida-pro;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.default ];
    environment.systemPackages = [ cfg.package ];
  };
}
