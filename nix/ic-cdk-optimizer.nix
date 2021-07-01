{ rustPlatform, fetchCrate, cmake, python3 }:
rustPlatform.buildRustPackage rec {
  pname = "ic-cdk-optimizer";
  version = "0.3.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "0v1vcd6ybmxhzkvqrnjlrmkxhby5cnay4n3n0iiksgk9394kprwk";
  };

  nativeBuildInputs = [ cmake python3 ];

  cargoSha256 = "03r8772sm7v82yz1v0cb0xnx347805kb0shrxwcjcc3rjxc4mk92";
  cargoDepsName = pname;
}
