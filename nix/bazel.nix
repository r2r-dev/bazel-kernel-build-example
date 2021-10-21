{ system ? builtins.currentSystem
, pkgs ? import ./nixpkgs.nix { inherit system; }
}:
let

  aplatform = pkgs.stdenv.mkDerivation {
    name = "android_platform";
    src = builtins.fetchGit {
      url =
        "https://android.googlesource.com/platform/build/bazel_common_rules";
      rev = "3b65aae27e728cb48560a6e76b8351c93c10d794";
    };
    phases = [ "unpackPhase" ];
  };

in
{

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

}
