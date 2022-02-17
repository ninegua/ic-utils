{ name, version, url, sha256, lib, fetchurl, stdenv, buildInputs ? [], findutils }:
let
   libPath = lib.makeLibraryPath buildInputs;
in stdenv.mkDerivation ({
  inherit name version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    tar zxf $src -C $out/bin &>/dev/null || install -m 755 $src $out/bin/${name}
    for file in $(${findutils}/bin/find $out/bin -type f); do
      patchelf --print-interpreter $file &>/dev/null && \
        echo Patching $file && \
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${libPath}" $file || true
    done
  '';
  src = fetchurl { inherit url sha256; };
  nationBuildInputs = [ findutils ];
  inherit buildInputs;
})
