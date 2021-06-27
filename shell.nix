{ pkgs ? import <nixpkgs> {} }:
let
  ihaskellSrc = 
    pkgs.fetchFromGitHub {
      owner = "gibiansky";
      repo = "IHaskell";
      rev = "4e1a2a132c165e1669faaeac355eb853e1f628a3";
      sha256 = "12h77j73wmznplkm5m4mmgj1qzm7f3mjyk7xmr9h1rw37m6xp72f";
      fetchSubmodules = true;
    };
  my_inline-r = pkgs.haskellPackages.callPackage ./nix/inline-r.nix {};

  rOverlay = rself: rsuper: {
    myR = rsuper.rWrapper.override {
      packages = with rsuper.rPackages; [ tidyverse rstan ];
    };
  };

  my_monad-bayes = pkgs.haskellPackages.callPackage ./nix/monad-bayes.nix {};
  haskellOverlay = hself: hsuper: {
    haskellPackages = pkgs.haskellPackages.override (old: {
    overrides = pkgs.lib.composeExtensions old.overrides
        (self: hspkgs: {
          monad-bayes = my_monad-bayes;
          inline-r = my_inline-r;
        });
      });
    };
  nixpkgs  = import <nixpkgs> { overlays = [ rOverlay haskellOverlay ]; };

  r-libs-site = nixpkgs.runCommand "r-libs-site" {
    buildInputs = with nixpkgs; [ R rPackages.tidyverse rPackages.rstan ];
  } ''echo $R_LIBS_SITE > $out'';

  ihaskellEnv = (import "${ihaskellSrc}/release.nix" {
    compiler = "ghc8104";
    nixpkgs  = nixpkgs;
    packages = self: [ self.inline-r self.monad-bayes];
  }).passthru.ihaskellEnv;

  systemPackages = self: [ self.myR ];

  jupyterlab = nixpkgs.python3.withPackages (ps: [ ps.jupyterlab ]);

  rtsopts = "-M3g -N2";

  ihaskellJupyterCmdSh = cmd: extraArgs: nixpkgs.writeScriptBin "ihaskell-${cmd}" ''
    #! ${nixpkgs.stdenv.shell}
    export GHC_PACKAGE_PATH="$(echo ${ihaskellEnv}/lib/*/package.conf.d| tr ' ' ':'):$GHC_PACKAGE_PATH"
    export R_LIBS_SITE=${builtins.readFile r-libs-site}
    export PATH="${nixpkgs.stdenv.lib.makeBinPath ([ ihaskellEnv jupyterlab ] ++ systemPackages nixpkgs)}''${PATH:+:}$PATH"
    ${ihaskellEnv}/bin/ihaskell install \
      -l $(${ihaskellEnv}/bin/ghc --print-libdir) \
      --use-rtsopts="${rtsopts}" \
      && ${jupyterlab}/bin/jupyter ${cmd} ${extraArgs} "$@"
  '';
  jupyterEnv = nixpkgs.buildEnv {
    name = "ihaskell-with-packages";
    buildInputs = [ nixpkgs.makeWrapper ];
    paths = [ ihaskellEnv jupyterlab ];
    postBuild = ''
      ln -s ${ihaskellJupyterCmdSh "lab" ""}/bin/ihaskell-lab $out/bin/
      ln -s ${ihaskellJupyterCmdSh "notebook" ""}/bin/ihaskell-notebook $out/bin/
      ln -s ${ihaskellJupyterCmdSh "nbconvert" ""}/bin/ihaskell-nbconvert $out/bin/
      ln -s ${ihaskellJupyterCmdSh "console" "--kernel=haskell"}/bin/ihaskell-console $out/bin/
      for prg in $out/bin"/"*;do
        if [[ -f $prg && -x $prg ]]; then
          wrapProgram $prg --set PYTHONPATH "$(echo ${jupyterlab}/lib/*/site-packages)"
        fi
      done
    '';
  };
in 
  pkgs.mkShell {
    name = "givewell-stan";
    buildInputs = [jupyterEnv];
  }

