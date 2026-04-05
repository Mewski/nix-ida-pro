{
  lib,
  stdenv,
  requireFile,
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
  kdePackages,

  forceWayland ? false,
  overrideSource ? null,
}:
stdenv.mkDerivation {
  pname = "ida-pro";
  version = "9.3sp1";

  src =
    if overrideSource != null then
      overrideSource
    else
      requireFile {
        name = "ida-pro_93_x64linux.run";
        url = "https://my.hex-rays.com/";
        sha256 = "095bf5114b7645236a1ee43b65f64aca7da3337ebc6e7f9799077db6f58cd307";
      };

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
