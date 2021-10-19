{ system ? builtins.currentSystem
, pkgs ? import ./nixpkgs.nix { inherit system; } }:
let

  aplatform = pkgs.stdenv.mkDerivation {
    name = "android_platform";
    src = builtins.fetchGit {
      url =
        "https://android.googlesource.com/platform/build/bazel_common_rules";
      rev = "3b65aae27e728cb48560a6e76b8351c93c10d794";
    };
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -R $src/* $out/ 
    '';
  };

in {

  kleaf = pkgs.stdenv.mkDerivation {
    name = "kleaf";
    src = builtins.fetchGit {
      url = "https://android.googlesource.com/kernel/build";
      rev = "e445436141744a005376d87b9c5f34f70fa5fc62";
    };
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [ ./01.kleaf.patch ];
    installPhase = ''
      mkdir -p $out/build
      cp -R ./* $out/build 
      cp -r ${aplatform.src} $out/build/bazel_common_rules
      ln -s $out/build/kleaf/bazel.WORKSPACE $out/WORKSPACE
    '';
  };

  linux = pkgs.stdenv.mkDerivation {
    name = "linux";
    src = builtins.fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.18.tar.gz";
      sha256 =
        "ca13fa5c6e3a6b434556530d92bc1fc86532c2f4f5ae0ed766f6b709322d6495";
    };
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [ ./02.kernel.patch ];
    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/ 
      echo PATH=${pkgs.glibc.bin}/bin:${pkgs.gnutar}/bin:${pkgs.gawk}/bin:${pkgs.perl}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.gnused}/bin:${pkgs.busybox}/bin:${pkgs.gnumake}/bin:${pkgs.gcc6}/bin:${pkgs.gzip}/bin:${pkgs.binutils-unwrapped}/bin:${pkgs.bc}/bin:${pkgs.python37}/bin >> $out/build.config.x86_64
      cat ${./build.config.x86_64} >> $out/build.config.x86_64
    '';
  };

}