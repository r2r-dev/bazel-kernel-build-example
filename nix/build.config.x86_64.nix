{ pkgs ? import ./nixpkgs.nix {
  config = { };
  overlays = [ ];
  system = builtins.currentSystem;
} }:

let
  kernel_x86_64_env = pkgs.buildEnv {
    name = "kernel_x86_64_env";
    paths = with pkgs; [
      bash
      bc
      binutils
      coreutils
      dateutils
      diffutils
      findutils
      gawk
      gcc6
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
    pathsToLink = [ "/bin" "/include" "/lib" ];
    ignoreCollisions = true;
  };
  build = pkgs.writeTextFile {
    name = "build.config.x86_64";
    text = ''
      PATH=${kernel_x86_64_env}/bin
      CPATH=${kernel_x86_64_env}/include
      LIBRARY_PATH=${kernel_x86_64_env}/lib
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
in pkgs.stdenv.mkDerivation {
  name = "kernel_x86_64_toolchain";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir $out
    ln -s ${build} $out/build.config.x86_64
  '';
}
