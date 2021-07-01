{ fetchurl, stdenv }:
stdenv.mkDerivation (rec {
  name = "motoko";
  version = "0.6.4";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    tar xvf $src -C $out/bin/
  '';
  src = fetchurl {
    url =
      "https://github.com/dfinity/motoko/releases/download/${version}/motoko-linux64-${version}.tar.gz";
    sha256 = "0a1xq8vz6siahbmnjrzzxn34dyq2myz402gyjgcv5hnr48zz7lwy";
  };
})
