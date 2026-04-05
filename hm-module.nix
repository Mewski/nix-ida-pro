{ self, ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.ida-pro;
in
{
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ self.overlays.default ];
    home.packages = [ cfg.package ];

    home.activation.idapyswitch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${cfg.package}/opt/ida-pro/idapyswitch -s ${lib.getLib pkgs.python3}/lib/libpython3.${lib.versions.majorMinor pkgs.python3.version}.so 2>/dev/null || true
    '';
  };
}
