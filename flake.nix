{
  description = "Project Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = (let
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
        bazel = pkgs.writeScriptBin "bazel" (''
          #!${pkgs.bash}/bin/bash
          # Set the JAVA_HOME to our JDK
          export JAVA_HOME=${pkgs.jdk8.home}
          export GIT_SSL_CAINFO="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        '' + pkgs.lib.optionalString (pkgs.buildPlatform.libc == "glibc") ''
          export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
        '' + ''
          exec ${pkgs.bazel_4}/bin/bazel "$@"
        '');
        oldpkgs = import (builtins.fetchTarball {
          # Descriptive name to make the store path easier to identify
          name = "nixos-unstable-2018-09-12";
          # Commit hash for nixos-unstable as of 2018-09-12
          url =
            "https://github.com/nixos/nixpkgs/archive/ca2ba44cab47767c8127d1c8633e2b581644eb8f.tar.gz";
          # Hash obtained using `nix-prefetch-url --unpack <url>`
          sha256 = "1jg7g6cfpw8qvma0y19kwyp549k1qyf11a5sg6hvn6awvmkny47v";
        }) { system = "x86_64-linux"; };
      in pkgs.mkShell {
        buildInputs = with pkgs; [
          rsync
          perl
          flex
          bison
          libelf
          oldpkgs.openssl.dev
          oldpkgs.openssl
          bc

          git
          cacert
          coreutils-full
          toybox
          curlFull
          gnutar
          gnused
          gawk
          # For Bazel rules
          nixFlakes
          bazel
          bazel-buildtools
        ];
        shellHook = ''
          # patch binary from toybox breaks some of bazel repository rules when running `bazel sync`
          # override path to force use of gnupatch instead
          export PATH="$${pkgs.gawk}/bin:{pkgs.gnupatch}/bin:${pkgs.gnutar}/bin:${pkgs.gnused}/bin:${pkgs.gcc6}/bin:''${PATH}"
          export WORKSPACE_ROOT="`pwd`"

          # Store debug output in a separate directory
          BAZEL_DEBUG="''${WORKSPACE_ROOT}/bazel-debug"
          if [ ! -d "''${BAZEL_DEBUG}" ]; then mkdir -p "''${BAZEL_DEBUG}"; fi

          source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
        '';
      });
    });
}
