{ stdenv, lib, makeWrapper, p7zip
, gawk, utillinux, xorg, glib, dbus-glib, zlib
, kernel ? null, libsOnly ? false
, fetchurl, undmg, perl
}:

assert (!libsOnly) -> kernel != null;

let xorgFullVer = lib.getVersion xorg.xorgserver;
    xorgVer = lib.versions.majorMinor xorgFullVer;
in
stdenv.mkDerivation rec {
  version = "${prl_major}.1.0-51516";
  prl_major = "17";
  pname = "prl-tools";

  # We download the full distribution to extract prl-tools-lin.iso from
  # => ${dmg}/Parallels\ Desktop.app/Contents/Resources/Tools/prl-tools-lin-arm.iso
  src = fetchurl {
    url = "https://download.parallels.com/desktop/v${prl_major}/${version}/ParallelsDesktop-${version}.dmg";
    sha256 = "sha256-jROtrSqL233TR9LGolLvn/fleiYfO02CFCCmtpSLLfQ=";
  };

  hardeningDisable = [ "pic" "format" ];

  nativeBuildInputs = [ p7zip undmg perl ]
    ++ lib.optionals (!libsOnly) [ makeWrapper ] ++ kernel.moduleBuildDependencies;

  buildInputs = with xorg; [ stdenv.cc.cc libXrandr libXext libX11 libXcomposite libXinerama ]
    ++ lib.optionals (!libsOnly) [ libXi glib dbus-glib zlib ];

  inherit libsOnly;

  unpackPhase = ''
    undmg < "${src}" || true

    export sourceRoot=prl-tools-build
    7z x "Parallels Desktop.app/Contents/Resources/Tools/prl-tools-lin-arm.iso" -o$sourceRoot
    if test -z "$libsOnly"; then
      ( cd $sourceRoot/kmods; tar -xaf prl_mod.tar.gz )
    fi
    ( cd $sourceRoot/tools/tools-arm64 )
  '';

  kernelVersion = if libsOnly then "" else lib.getVersion kernel.name;
  kernelDir = if libsOnly then "" else "${kernel.dev}/lib/modules/${kernelVersion}";
  scriptPath = lib.concatStringsSep ":" (lib.optionals (!libsOnly) [ "${utillinux}/bin" "${gawk}/bin" ]);

  buildPhase = ''
    if test -z "$libsOnly"; then
      ( # kernel modules
        cd kmods
        make -f Makefile.kmods \
          KSRC=$kernelDir/source \
          HEADERS_CHECK_DIR=$kernelDir/source \
          KERNEL_DIR=$kernelDir/build \
          SRC=$kernelDir/build \
          KVER=$kernelVersion
      )
    fi
  '';

  installPhase = ''
    if test -z "$libsOnly"; then
      ( # kernel modules
        cd kmods
        mkdir -p $out/lib/modules/${kernelVersion}/extra
        cp prl_tg/Toolgate/Guest/Linux/prl_tg/prl_tg.ko $out/lib/modules/${kernelVersion}/extra
        cp prl_fs/SharedFolders/Guest/Linux/prl_fs/prl_fs.ko $out/lib/modules/${kernelVersion}/extra
        cp prl_fs_freeze/Snapshot/Guest/Linux/prl_freeze/prl_fs_freeze.ko $out/lib/modules/${kernelVersion}/extra
        )
    fi

    ( # tools
      cd tools/tools-arm64
      mkdir -p $out/lib

      if test -z "$libsOnly"; then
        # install binaries
        for i in bin/* sbin/prl_nettool sbin/prl_snapshot; do
          install -Dm755 $i $out/$i
        done

        mkdir -p $out/bin
        install -Dm755 ../../tools/prlfsmountd.sh $out/sbin/prlfsmountd
        wrapProgram $out/sbin/prlfsmountd \
          --prefix PATH ':' "$scriptPath"

        for i in lib/*.0.0; do
          cp $i $out/lib
        done

        mkdir -p $out/share/man/man8
        install -Dm644 ../mount.prl_fs.8 $out/share/man/man8

        mkdir -p $out/etc/pm/sleep.d
        install -Dm644 ../99prltoolsd-hibernate $out/etc/pm/sleep.d

      fi

      cd $out/lib
      ln -s libPrlWl.so.1.0.0 libPrlWl.so.1
    )
  '';

  meta = with lib; {
    description = "Parallels Tools for Linux guests";
    homepage = "https://parallels.com";
    platforms = [ "aarch64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ fetsorn ];
    priority = 4;
  };
}
