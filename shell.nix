{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  ic-cdk-optimizer = callPackage ./nix/ic-cdk-optimizer.nix {};
  cdk-rs = callPackage ./nix/cdk-rs.nix {};
  agent-rs = callPackage ./nix/agent-rs.nix {};
  motoko = import ./nix/motoko.nix { inherit stdenv fetchurl; };
  quill = import ./nix/quill.nix { inherit stdenv fetchurl; };
  vessel = import (builtins.fetchGit {
    url = "https://github.com/ninegua/vessel";
    #ref = "main";
    rev = "0958c2a679eff33a600667764a5f60b0bd75bc4a";
  }) { nixpkgs = pkgs; };
in with pkgs;
stdenv.mkDerivation {
  name = "hello";
  nativeBuildInputs = [
    agent-rs
    binaryen
    gnumake
    ic-cdk-optimizer
    jq
    motoko
    nixfmt
    protobuf
    quill
    vessel.vessel
    xxd
  ];
}
