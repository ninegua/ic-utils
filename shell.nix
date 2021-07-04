let
  nixpkgs = builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "nixos-20.09";
    url = "https://github.com/nixos/nixpkgs/";
    ref = "refs/heads/nixos-20.09";
    rev = "cd63096d6d887d689543a0b97743d28995bc9bc3";
  };
  moz_overlay = import (builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");
  pkgs = import nixpkgs { overlays = [ moz_overlay ]; };
in with pkgs;
let
  #ic-cdk-optimizer = callPackage ./nix/ic-cdk-optimizer.nix {};
  cdk-rs = import ./nix/cdk-rs.nix { inherit pkgs; };
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
    cdk-rs
    gnumake
    #ic-cdk-optimizer
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
