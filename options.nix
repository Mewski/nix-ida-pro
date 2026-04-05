{ lib, pkgs, ... }:
{
  options = {
    programs.ida-pro = {
      enable = lib.mkEnableOption "IDA Pro";
      package = lib.mkOption {
        type = lib.types.package;
        description = ''
          Package to install.

          This overlay provides the following packages:
          - `ida-pro`
          - `ida-pro-wayland`
        '';
        default = pkgs.ida-pro;
        defaultText = lib.literalExpression "pkgs.ida-pro";
        example = lib.literalExpression ''
          pkgs.ida-pro-wayland.override {
            overrideSource = ./ida-pro_93_x64linux.run;
          };
        '';
      };
    };
  };
}
