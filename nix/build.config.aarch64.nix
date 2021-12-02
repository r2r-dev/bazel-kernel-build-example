{ pkgs ? import ./nixpkgs.nix {
    config = { };
    overlays = [ ];
    system = builtins.currentSystem;
  }
}:

let
  crossPkgs = pkgs.pkgsCross.aarch64-multiplatform;

  packages = with crossPkgs.buildPackages; [
    bash
    bc
    binutils-unwrapped
    coreutils
    dateutils
    diffutils
    findutils
    gawk
    gcc7
    glibc.bin
    gnugrep
    gnumake
    gnused
    gnutar
    gzip
    perl
    which
    python37
    pkgconfig

    libelf
    openssl
    openssl.dev
    openssl.out
  ] ++ [
    pkgs.gcc
  ];

  bins = pkgs.lib.strings.makeSearchPathOutput "bin" "bin" packages;
  libs = pkgs.lib.strings.makeSearchPathOutput "lib" "lib" packages;
  clibs = pkgs.lib.strings.makeSearchPathOutput "lib" "lib" [
    crossPkgs.glibc
  ];
  inc = pkgs.lib.strings.makeSearchPathOutput "dev" "include" [
    crossPkgs.openssl
    crossPkgs.libelf
  ];
  build = pkgs.writeTextFile {
    name = "build.config";
    text = ''
      PATH=${bins}
      CPATH=${inc}
      LIBRARY_PATH=${libs}
      HOSTCC=gcc
      CC=aarch64-unknown-linux-gnu-gcc
      LD=aarch64-unknown-linux-gnu-ld
      ARCH=arm64
      LLVM_IAS=0
      DEFCONFIG=defconfig


      MAKE_GOALS="
      Image
      modules
      "

      FILES="
      arch/arm64/boot/Image
      vmlinux
      System.map
      vmlinux.symvers
      modules.builtin
      modules.builtin.modinfo
      "
      POST_DEFCONFIG_CMDS="include"
      function include() {
        make -C ''${KERNEL_DIR} ''${TOOL_ARGS} O=''${OUT_DIR} include
      }
    '';
  };
in
pkgs.stdenv.mkDerivation {
  name = "kernel_aarch64_toolchain";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    ln -s ${build} $out/build.config
  '';
}

