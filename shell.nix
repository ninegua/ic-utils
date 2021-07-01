{ pkgs ? import <nixpkgs> { } }:
let
  ic-cdk-optimizer = with pkgs; callPackage ./nix/ic-cdk-optimizer.nix {};
  cdk-rs = with pkgs; callPackage ./nix/cdk-rs.nix {};
  agent-rs = with pkgs; callPackage ./nix/agent-rs.nix {};
  motoko = with pkgs; import ./nix/motoko.nix { inherit stdenv fetchurl; };
  vessel = import (builtins.fetchGit {
    url = "https://github.com/ninegua/vessel";
    ref = "main";
  }) { nixpkgs = pkgs; };
in with pkgs;
stdenv.mkDerivation {
  name = "hello";
  nativeBuildInputs = [
    ic-cdk-optimizer
    agent-rs
    vessel.vessel
    motoko
    nodejs
    gnumake
    gperf
    nodePackages.prettier
    nodePackages.node2nix
    pkgsCross.wasi32.buildPackages.clang_10
    xxd
    lld_10
    nixfmt
    binaryen
  ];
}
