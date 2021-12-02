{ pkgs ? import ./nixpkgs.nix {
    config = { };
    overlays = [ ];
    system = builtins.currentSystem;
  }
}:

let
  packages = with pkgs; [
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

    libelf
    openssl
    openssl.dev
    openssl.out
  ];

  bins = pkgs.lib.strings.makeSearchPathOutput "bin" "bin" packages;
  libs = pkgs.lib.strings.makeSearchPathOutput "lib" "lib" packages;
  inc = pkgs.lib.strings.makeSearchPathOutput "dev" "include" [
    pkgs.openssl
    pkgs.libelf
  ];
  build = pkgs.writeTextFile {
    name = "build.config";
    text = ''
      PATH=${bins}
      CPATH=${inc}
      LIBRARY_PATH=${libs}
      ARCH=x86_64
      LLVM_IAS=0
      DEFCONFIG=defconfig


      MAKE_GOALS="
      bzImage
      modules
      "

      FILES="
      arch/x86/boot/bzImage
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
  name = "kernel_x86_64_toolchain";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    ln -s ${build} $out/build.config
  '';
}

