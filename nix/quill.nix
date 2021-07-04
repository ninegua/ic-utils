{ fetchurl, stdenv }:
stdenv.mkDerivation (rec {
  name = "quill";
  version = "0.2.0";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $quill $out/bin/quill
    chmod a+x $out/bin/quill
  '';
  quill = fetchurl {
    url =
      "https://github.com/dfinity/quill/releases/download/v${version}/quill-linux-x86_64";
    sha256 = "1msgj7y8b0bh0sq14msa5jqwfn9yzwiin5l276qz0h0wjqmnndbs";
  };
})
