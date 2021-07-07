{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  download = callPackage ./nix/download.nix;
  didc = download (rec {
    name = "didc";
    version = "linux-static-build";
    url =
      "https://github.com/ninegua/candid/releases/download/${version}/didc-linux-musl-x86_64";
    sha256 = "0gxjhqkyvlf6jcnmiqhri08qyap6sdd433z3pzc975d37x4rgblq";
  });
  icx = download (rec {
    name = "icx";
    version = "static-release-build";
    url =
      "https://github.com/ninegua/agent-rs/releases/download/${version}/icx-linux-x86_64";
    sha256 = "0f8xhw7rxjsa6jjyh8f49h3xrar479pmaf1byxlyrwsb2bi93c9v";
  });
  icx-proxy = download (rec {
    name = "icx-proxy";
    version = "static-release-build";
    url =
      "https://github.com/ninegua/agent-rs/releases/download/${version}/icx-proxy-linux-x86_64";
    sha256 = "1flhcvlz5s1gzs09ss3s2lz1vj3f4xw714r8z2c7hzxkb9k7ah4r";
  });
  motoko = download (rec {
    name = "motoko";
    version = "0.6.4";
    url =
      "https://github.com/dfinity/motoko/releases/download/${version}/motoko-linux64-${version}.tar.gz";
    sha256 = "0a1xq8vz6siahbmnjrzzxn34dyq2myz402gyjgcv5hnr48zz7lwy";
  });
  quill = download (rec {
    name = "quill";
    version = "0.2.0";
    url =
      "https://github.com/dfinity/quill/releases/download/v${version}/quill-linux-x86_64";
    sha256 = "1msgj7y8b0bh0sq14msa5jqwfn9yzwiin5l276qz0h0wjqmnndbs";
  });
  vessel = download (rec {
    name = "vessel";
    version = "static-linux-build";
    url =
      "https://github.com/ninegua/vessel/releases/download/${version}/vessel-linux64-static";
    sha256 = "0n0scnhm0dzshw5f3gairgr4pl6mg1q66zk2sv9757qfyc9jqsxc";
  });
  keysmith = callPackage ./nix/keysmith.nix { };
  filter = name: type:
    let baseName = baseNameOf (toString name);
    in !(baseName == "dist-newstyle" || lib.hasSuffix ".vim" baseName || baseName == "target")
    && lib.sources.cleanSourceFilter name type;
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
    #rustc
    #cargo
  ];
}
