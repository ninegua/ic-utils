{ rustPlatform, cmake, python3 }:
rustPlatform.buildRustPackage rec {
  pname = "agent-rs";
  version = "1.0.0";
  nativeBuildInputs = [ cmake python3 ];
  src = builtins.fetchGit {
          url = "https://github.com/ninegua/cdk-rs";
          rev = "bc90c436247fe36036cbd8bc53a87b1937756ae6";
        };
  cargoSha256 = "11x6ipiv119ad4inczyr60ag4ih8ipqaxxdri7lvdvcs2k8ris0y";
  verifyCargoDeps = true;
}
