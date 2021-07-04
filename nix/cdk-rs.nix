{ pkgs }:
let
  rustc = pkgs.rustChannels.nightly.rust.override {
    targets = [ "x86_64-unknown-linux-musl" ];
  };
  rustPlatform = pkgs.makeRustPlatform {
    cargo = rustc;
    rustc = rustc;
  };
in rustPlatform.buildRustPackage {
  pname = "cdk-rs";
  version = "1.0.0";
  nativeBuildInputs = [ pkgs.cmake pkgs.python3 ];
  src = builtins.fetchGit {
    url = "https://github.com/ninegua/cdk-rs";
    rev = "bc90c436247fe36036cbd8bc53a87b1937756ae6";
  };
  cargoSha256 = "1kggkm2ckch43v9q804z36lgqfziw3b52kz15d31bwq4my9zv99b";
  CARGO_BUILD_TARGET = [ "x86_64-unknown-linux-musl" ];
  target = "x86_64-unknown-linux-musl";
  CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER =
    "${pkgs.llvmPackages_10.lld}/bin/lld";
  verifyCargoDeps = true;
}
