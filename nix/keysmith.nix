{ buildGo116Module, fetchFromGitHub, lib }:
buildGo116Module rec {
  pname = "keysmith";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "dfinity";
    repo = "keysmith";
    rev = "3e2de90bc268392b3000b45c307bf6a123ad04c0";
    sha256 = "1z0sxirk71yabgilq8v5lz4nd2bbm1xyrd5zppif8k9jqhr6v3v3";
  };

  subPackages = [ "." ];

  vendorSha256 = "1p0r15ihmnmrybf12cycbav80sdj2dv2kry66f4hjfjn6k8zb0dc";

  runVend = false;
  meta = with lib; {
    description =
      "Hierarchical Deterministic Key Derivation for the Internet Computer";
    homepage = "https://github.com/dfinity/keysmith";
    license = licenses.mit;
  };
  buildFlags = [ "-ldflags='-extldflags=-static'" ];
  CGO_ENABLED = "0";
}
