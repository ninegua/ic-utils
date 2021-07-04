{ fetchurl, stdenv }:
stdenv.mkDerivation (rec {
  pname = "agent-rs";
  version = "static-release-build";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $icx $out/bin/icx
    cp $icxproxy $out/bin/icx-proxy
    chmod a+x $out/bin/*
  '';
  icx = fetchurl {
    url =
      "https://github.com/ninegua/agent-rs/releases/download/${version}/icx-linux-x86_64";
    sha256 = "0f8xhw7rxjsa6jjyh8f49h3xrar479pmaf1byxlyrwsb2bi93c9v";
  };
  icxproxy = fetchurl {
    url =
      "https://github.com/ninegua/agent-rs/releases/download/${version}/icx-proxy-linux-x86_64";
    sha256 = "1flhcvlz5s1gzs09ss3s2lz1vj3f4xw714r8z2c7hzxkb9k7ah4r";
  };
})
