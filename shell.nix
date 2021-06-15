{ pkgs ? import <nixpkgs> {} }:
let
  R-with-my-packages = pkgs.rWrapper.override { packages = with pkgs.rPackages; [ 
    rstan 
    ggplot2 
    StanHeaders 
    tidyverse
  ]; };
in
pkgs.mkShell {
  name = "stan-env";
  buildInputs = [ R-with-my-packages ];
}
