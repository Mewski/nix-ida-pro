{
  lib,
  stdenv,
  callPackage,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  libGL,
  glib,
  fontconfig,
  freetype,
  xorg,
  dbus,
  libxkbcommon,
  wayland,
  libdrm,
  gtk3,
  python3,
  zlib,
  libxcrypt,
  curl,
  openssl,
  kdePackages,

  forceWayland ? false,
  overrideSource ? null,
}:
let
  sources = callPackage ./sources.nix { };
  source =
    if overrideSource != null then
      overrideSource
    else if builtins.hasAttr stdenv.hostPlatform.system sources.platforms then
      sources.platforms.${stdenv.hostPlatform.system}
    else
      throw "No IDA Pro source for system ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "ida-pro";
  inherit (sources) version;
  src = source;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    libGL
    glib
    fontconfig
    freetype
    xorg.libX11
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilrenderutil
    xorg.xcbutilkeysyms
    xorg.xcbutilwm # libxcb-icccm
    xorg.xcbutilcursor
    libxkbcommon
    dbus
    wayland
    libdrm
    gtk3
    zlib
    (libxcrypt.override { enableHashes = "all"; })
    curl
    openssl
    stdenv.cc.cc.lib # libstdc++
    python3
    kdePackages.qtbase
    kdePackages.qtwayland
  ];

  appendRunpaths = [ "${lib.getLib python3}/lib" ];

  dontUnpack = true;

  buildPhase = ":";

  desktopItems = [
    (makeDesktopItem {
      name = "IDA Pro";
      exec = "ida";
      icon = "ida-pro";
      desktopName = "IDA Pro";
      comment = "Interactive Disassembler and Decompiler";
      categories = [ "Development" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/opt/ida-pro
    mkdir -p $out/share/pixmaps

    export HOME=$(mktemp -d)
    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --prefix $out/opt/ida-pro

    rm -f $out/opt/ida-pro/*.desktop
    cp $out/opt/ida-pro/appico.png $out/share/pixmaps/ida-pro.png

    chmod +x $out/opt/ida-pro/ida
    chmod +x $out/opt/ida-pro/idat

    makeWrapper $out/opt/ida-pro/ida $out/bin/ida \
      ${lib.optionalString forceWayland "--set QT_QPA_PLATFORM wayland"}

    makeWrapper $out/opt/ida-pro/idat $out/bin/idat

    runHook postInstall
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Interactive Disassembler and Decompiler by Hex-Rays";
    homepage = "https://hex-rays.com/ida-pro/";
    mainProgram = "ida";
    platforms = [ "x86_64-linux" ];
  };
}
