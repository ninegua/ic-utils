{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  download = callPackage ./nix/download.nix;
  ic-repl = download (rec {
    name = "ic-repl";
    version = "0.1.3";
    url =
      "https://github.com/chenyan2002/ic-repl/releases/download/${version}/ic-repl-linux64";
    sha256 = "11ajgkyfr7wprai3kg0sk3qrwdxsr5hz94lm8pkvshnifd7gmb24";
    buildInputs = [ openssl.out ];
  });
  didc = download (rec {
    name = "didc";
    version = "2022-01-06";
    url =
      "https://github.com/dfinity/candid/releases/download/${version}/didc-linux64";
    sha256 = "003pf5jcsm7avc7b83qf90cf8g7xw023a1r8y1cbl94n2hcj5rbg";
  });
  icx = download (rec {
    name = "icx";
    version = "9518bbd";
    url =
      "https://github.com/ninegua/agent-rs/releases/download/${version}/binaries-linux.tar.gz";
    sha256 = "1jlzkrflrbl491d13q119dfv4rskh0rl3bb0q68dr78xkfb7fyvh";
  });
  icx-proxy = download (rec {
    name = "icx-proxy";
    version = "5967469";
    url =
      "https://github.com/dfinity/icx-proxy/releases/download/${version}/binaries-linux.tar.gz";
    sha256 = "08k7zvchkkwppc18f64dzhfc39sw14pg3lsygv95rpv2v5m0jpm2";
  });
  motoko = download (rec {
    name = "motoko";
    version = "0.6.21";
    url =
      "https://github.com/dfinity/motoko/releases/download/${version}/motoko-linux64-${version}.tar.gz";
    sha256 = "1aipcwp69vqnaw4ppx0nxh2ji12k332fg0vr9l0lxjfavqwnvqv4";
  });
  quill = download (rec {
    name = "quill";
    version = "0.2.14.hsm";
    url =
      "https://github.com/dfinity/quill/releases/download/v${version}/quill-linux-x86_64";
    sha256 = "0cqpww4qb7ip7v7h9di1bxw35qrcl8hn5rf36v9sylgx0gc0fval";
  });
  vessel = download (rec {
    name = "vessel";
    version = "v0.6.2";
    url =
      "https://github.com/dfinity/vessel/releases/download/${version}/vessel-linux64";
    sha256 = "1d0djh2m2m86zrbpwkpr80mfxccr2glxf6kq15hpgx48m74lsmsp";
    buildInputs = [ openssl.out ];
  });
  keysmith = callPackage ./nix/keysmith.nix { };
  filter = name: type:
    let baseName = baseNameOf (toString name);
    in !(baseName == "dist-newstyle" || lib.hasSuffix ".vim" baseName
      || baseName == "target") && lib.sources.cleanSourceFilter name type;
  cleanSource = src: lib.sources.cleanSourceWith { inherit filter src; };
in stdenv.mkDerivation {
  name = "ic-utils";
  version = "0.1.0-pre";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    install -m 755 ${didc}/bin/* $out/bin/
    install -m 755 ${icx}/bin/* $out/bin/
    install -m 755 ${icx-proxy}/bin/* $out/bin/
    install -m 755 ${motoko}/bin/* $out/bin/
    install -m 755 ${quill}/bin/* $out/bin/
    install -m 755 ${vessel}/bin/* $out/bin/
    install -m 755 ${keysmith}/bin/* $out/bin/
    install -m 755 $src/bin/* $out/bin/
    cp -r $src/share $out/
  '';
  src = cleanSource ./.;
  nativeBuildInputs = [
    binaryen
    didc
    gnumake
    icx
    icx-proxy
    jq
    keysmith
    motoko
    nixfmt
    protobuf
    shfmt
    quill
    vessel
    xxd
    ic-repl
    #rustc
    #cargo
  ];
}
