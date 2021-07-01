{ rustPlatform, cmake, python3 }:
rustPlatform.buildRustPackage rec {
  pname = "agent-rs";
  version = "1.0.0";
  #buildInputs = [ openssl ];
  nativeBuildInputs = [ cmake python3 ];
  src = builtins.fetchGit "https://github.com/ninegua/cdk-rs";
  cargoSha256 = "11x6ipiv119ad4inczyr60ag4ih8ipqaxxdri7lvdvcs2k8ris0y";
  #cargoBuildOptions = x: x ++ [ "-p" "icx" "-p" "icx-proxy" ];
  #cargoTestOptions = x: x ++ [ "-p" "icx" "-p" "icx-proxy" ];
  verifyCargoDeps = true;
}
