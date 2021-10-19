{ pkgs ? import ./nixpkgs.nix {
  config = { };
  overlays = [ ];
  system = builtins.currentSystem;
} }:

let
  oldpkgs = import (builtins.fetchTarball {
    name = "nixos-unstable-2018-09-12";
    url =
      "https://github.com/nixos/nixpkgs/archive/ca2ba44cab47767c8127d1c8633e2b581644eb8f.tar.gz";
    sha256 = "1jg7g6cfpw8qvma0y19kwyp549k1qyf11a5sg6hvn6awvmkny47v";
  }) { system = "x86_64-linux"; };

  kernel_x86_64_env = pkgs.buildEnv {
    name = "kernel_x86_64_env";
    paths = with pkgs; [
      diffutils.out
      glibc.bin
      gnutar
      gnugrep
      gawk
      perl
      coreutils
      binutils
      bash
      gnused
      which
      gnumake
      gcc6
      gzip
      bc
      python37

      oldpkgs.openssl.dev
      oldpkgs.openssl.out
      pkgs.libelf.out
    ];
    pathsToLink = [ "/bin" "/include" "/lib" ];
    ignoreCollisions = true;
  };
  build = pkgs.writeTextFile {
    name = "build.config.x86_64";
    text = ''
      KERNEL_DIR=external/linux
      PATH=${kernel_x86_64_env}/bin
      CPATH=${kernel_x86_64_env}/include
      LIBRARY_PATH=${kernel_x86_64_env}/lib
      ARCH=x86_64
      LLVM_IAS=0
      SKIP_MRPROPER=0
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
    '';
  };
in pkgs.stdenv.mkDerivation {
  name = "kernel_x86_64_toolchain";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    ln -s ${build} $out/build.config.x86_64
  '';
}
