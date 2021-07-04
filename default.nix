{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  agent-rs = callPackage ./nix/agent-rs.nix { };
  motoko = callPackage ./nix/motoko.nix { };
  quill = callPackage ./nix/quill.nix { };
  vessel = callPackage ./nix/vessel.nix { };
in with pkgs;
stdenv.mkDerivation {
  name = "hello";
  nativeBuildInputs = [
    agent-rs
    binaryen
    gnumake
    jq
    motoko
    nixfmt
    protobuf
    shfmt
    quill
    vessel
    xxd
  ];
}
