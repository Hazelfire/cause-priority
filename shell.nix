{ pkgs ? import <nixpkgs> {} }:
let
  jupyter = import (
    pkgs.fetchFromGitHub {
      owner = "tweag";
      repo = "jupyterWith";
      rev = "acf20ff7e3b45bd2978326e17f0de6e2f45c687f";
      sha256 = "0i77c9wcnm0jj6czsy6vnf1f8ydzifddz2z7wz0afnpabl4kv3wn";
      fetchSubmodules = true;
    }) {};

  my_inline_r = pkgs.haskellPackages.callPackage ./nix/inline-r.nix {};
  iHaskell = jupyter.kernels.iHaskellWith {
    extraIHaskellFlags = "--codemirror Haskell";  # for jupyterlab syntax highlighting
    name = "haskell";
    packages = p: with p; [ hvega formatting my_inline_r ];
  };

  irkernel = jupyter.kernels.iRWith {
    # Identifier that will appear on the Jupyter interface.
    name = "nixpkgs";
    # Libraries to be available to the kernel.
    packages = p: with p; [ 
      rstan 
      ggplot2 
      StanHeaders 
      tidyverse
    ];
    # Optional definition of `rPackages` to be used.
    # Useful for overlaying packages.
    rPackages = pkgs.rPackages;
  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ irkernel iHaskell ];
    };
in
  jupyterEnvironment.env

