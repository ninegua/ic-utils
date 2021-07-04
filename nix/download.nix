{ name, version, url, sha256, fetchurl, stdenv }:
stdenv.mkDerivation ({
  inherit name version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    tar zxvf $src -C $out/bin 2> /dev/null || install -m 755 $src $out/bin/${name}
  '';
  src = fetchurl { inherit url sha256; };
})
