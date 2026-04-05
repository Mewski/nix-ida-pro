{
  lib,
  requireFile,
  ...
}:
let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  version = data.version;
  mkSource =
    name:
    requireFile {
      inherit name;
      url = "https://my.hex-rays.com/";
      sha256 = data.hashes.${name};
    };
in
{
  inherit version;
  platforms = lib.mapAttrs (system: name: mkSource name) data.platforms;
}
