{ rustPlatform, openssl, pkg-config }:
rustPlatform.buildRustPackage rec {
  pname = "agent-rs";
  version = "1.0.0";
  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];
  src = builtins.fetchGit {
    url = "https://github.com/ninegua/agent-rs";
    ref = "main";
  };
  cargoSha256 = "0616yijw98bp6hxlg1ijg8ir09f9rsprw9ni643bjbd6109vn4g7";
  #cargoBuildOptions = x: x ++ [ "-p" "icx" "-p" "icx-proxy" ];
  #cargoTestOptions = x: x ++ [ "-p" "icx" "-p" "icx-proxy" ];
  verifyCargoDeps = true;
}
