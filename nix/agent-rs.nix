{ rustPlatform, openssl, pkg-config }:
rustPlatform.buildRustPackage rec {
  pname = "agent-rs";
  version = "1.0.0";
  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];
  src = builtins.fetchGit {
    url = "https://github.com/ninegua/agent-rs";
    rev = "0794b530ce457418850e239aed3c3b29bec69da6";
  };
  cargoSha256 = "0616yijw98bp6hxlg1ijg8ir09f9rsprw9ni643bjbd6109vn4g7";
  verifyCargoDeps = true;
}
