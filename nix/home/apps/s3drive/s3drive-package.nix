{ lib, stdenv, fetchurl, makeWrapper, dpkg, autoPatchelfHook
, flutter, mpv, libgcc, libstdcxx5, glib, gtk3, cairo, pango, harfbuzz, atk
, gdk-pixbuf, zlib, libayatana-common, libayatana-indicator, libayatana-appindicator
, libsecret, libjson, libdbusmenu, libdbusmenu-gtk3, libsodium, jsoncpp
, xorg, libselinux, libsepol, pcre, util-linux, dbus, xdg-desktop-portal
, libepoxy, libglvnd
}:

stdenv.mkDerivation rec {
  pname = "s3drive";
  version = "1.9.7";
  src = fetchurl {
    url = "https://github.com/s3drive/deb-app/releases/download/${version}/s3drive_amd64.deb";
    sha256 = "1996c41998cd62396996d9a06c8821a463b0569531e91c64db0246f4b6207eec";
  };
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];
  buildInputs = [
    mpv
    flutter
    libgcc
    libstdcxx5
    glib
    gtk3
    cairo
    pango
    harfbuzz
    atk
    gdk-pixbuf
    zlib
    libayatana-common
    libayatana-indicator
    libayatana-appindicator
    libsecret
    libjson
    libdbusmenu
    libdbusmenu-gtk3
    libsodium
    jsoncpp
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    libselinux
    libsepol
    pcre
    util-linux
    dbus
    xdg-desktop-portal
    libepoxy
    libglvnd
  ];
  unpackPhase = ''
    ${dpkg}/bin/dpkg-deb -x $src $TMPDIR
  '';
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib,share}
    cp -r $TMPDIR/usr/local/lib/s3drive/* $out/
    ln -s ${mpv}/lib/libmpv.so.2 $out/lib/libmpv.so.1
    makeWrapper $out/kapsa $out/bin/s3drive-wrapped \
      --prefix PATH : ${lib.makeBinPath [ flutter dbus xdg-desktop-portal ]} \
      --prefix LD_LIBRARY_PATH : $out/lib:${lib.makeLibraryPath buildInputs} \
      --set GDK_BACKEND x11 \
      --set FLUTTER_ENGINE ${flutter}/bin/cache/artifacts/engine/linux-x64 \
      --set FLUTTER_ROOT ${flutter} \
      --set FLUTTER_ASSETS $out/data/flutter_assets \
      --set AOT_LIBRARY $out/lib/libapp.so \
      --set XDG_DATA_DIRS "$XDG_DATA_DIRS:${xdg-desktop-portal}/share" \
      --set GSETTINGS_SCHEMA_DIR "${glib.getSchemaPath gtk3}" \
      --set GIO_MODULE_DIR "${glib.getSchemaPath glib}/gio/modules"
    runHook postInstall
  '';
  meta = with lib; {
    description = "Zero Knowledge E2E encrypted storage compatible with any S3 provider.";
    homepage = "https://s3drive.app";
    license = licenses.unfree;
    maintainers = [ maintainers.smantzavinos ];
    platforms = [ "x86_64-linux" ];
  };
}
