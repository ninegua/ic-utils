{ fetchurl, stdenv }:
stdenv.mkDerivation (rec {
  name = "vessel";
  version = "static-linux-build";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $vessel $out/bin/vessel
    chmod a+x $out/bin/vessel
  '';
  vessel = fetchurl {
    url =
      "https://github.com/ninegua/vessel/releases/download/${version}/vessel-linux64-static";
    sha256 = "0n0scnhm0dzshw5f3gairgr4pl6mg1q66zk2sv9757qfyc9jqsxc";
  };
})
