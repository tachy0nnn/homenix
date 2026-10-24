{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glib,
  nss,
  nspr,
  atk,
  at-spi2-atk,
  at-spi2-core,
  dbus,
  cups,
  expat,
  libxkbcommon,
  alsa-lib,
  mesa,
  libglvnd,
  vulkan-loader,
  libX11,
  libxcb,
  libXext,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXfixes,
  libXrandr,
  cairo,
  pango,
  gdk-pixbuf,
  systemd,
  pciutils,
  pipewire,
  libpulseaudio,
}:

let
  version = "0.20.1.1";

  # libraries the binary links against, plus the ones chromium dlopen()s at runtime
  runtimeLibs = [
    glib
    nss
    nspr
    atk
    at-spi2-atk
    at-spi2-core
    dbus
    cups
    expat
    libxkbcommon
    alsa-lib
    mesa
    libglvnd
    vulkan-loader
    libX11
    libxcb
    libXext
    libXcomposite
    libXcursor
    libXdamage
    libXfixes
    libXrandr
    cairo
    pango
    gdk-pixbuf
    systemd
    pciutils
    pipewire
    libpulseaudio
  ];
in
stdenv.mkDerivation {
  pname = "helium";
  inherit version;

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
    hash = "sha256-ICP6RM76D70+GQcch+kNYSdfCLqPW0jVjCNSFVZem1M=";
  };

  sourceRoot = "helium-${version}-x86_64_linux";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeLibs;

  # the qt shims are only loaded when a qt platform integration is in use,
  # so a missing qt should not fail the build
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/helium
    cp -a . $out/share/helium/

    # mirrors the upstream helium-wrapper script, but points at the nix store
    # and adds /run/opengl-driver/lib so GPU drivers (e.g. nvidia) are found
    makeWrapper $out/share/helium/helium $out/bin/helium \
      --set CHROME_WRAPPER $out/bin/helium \
      --set CHROME_VERSION_EXTRA nixos \
      --prefix LD_LIBRARY_PATH : "$out/share/helium:/run/opengl-driver/lib:${lib.makeLibraryPath runtimeLibs}"

    install -Dm644 helium.desktop $out/share/applications/helium.desktop
    install -Dm644 product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

    runHook postInstall
  '';

  meta = {
    description = "Helium Browser for Linux (repackaged upstream release)";
    homepage = "https://github.com/imputnet/helium-linux";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
    license = with lib.licenses; [
      gpl3Only
      bsd3
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "helium";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
