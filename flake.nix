{
  description = "Flake for building IDA Pro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      mkPackages = pkgs: {
        ida-pro = pkgs.callPackage ./package.nix { };
        ida-pro-wayland = pkgs.callPackage ./package.nix { forceWayland = true; };
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = mkPackages pkgs;
      in
      {
        packages = packages // {
          default = packages.ida-pro;
        };
      }
    )
    // {
      overlays.default = final: prev: mkPackages prev;
      nixosModules.ida-pro = import ./module.nix inputs;
      hmModules.ida-pro = import ./hm-module.nix inputs;
    };
}
