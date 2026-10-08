{ lib, stdenv, fetchurl }:

let
  version = "1.0.0";
  platform =
    if stdenv.hostPlatform.isDarwin then
      if stdenv.hostPlatform.isAarch64
        then { arch = "aarch64"; os = "apple-darwin"; hash = "sha256-l1DQ/EG/JXIOszxAS0IB630I1Fdi9g6tIcS5JRMpYpA="; }
        else { arch = "x86_64";  os = "apple-darwin"; hash = "sha256-54AV2tgC8VKFMVa3slp1Y+8rLgvqj6Ctqxho5zReHzw="; }
    else
      if stdenv.hostPlatform.isAarch64
        then { arch = "aarch64"; os = "unknown-linux-musl"; hash = "sha256-5k8/tXZtgDuTEWZI+xXQKCg8JKqR30knrYZECGst9ME="; }
        else { arch = "x86_64";  os = "unknown-linux-musl"; hash = "sha256-6EmcG2VZpzTzMS/IhqedvaZct5MVbpvoVEHcypRzqdA="; };
  target = "${platform.arch}-${platform.os}";
in
stdenv.mkDerivation {
  pname = "jquants-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/J-Quants/jquants-cli/releases/download/v${version}/jquants-${version}-${target}.tar.gz";
    hash = platform.hash;
  };

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 jquants $out/bin/jquants
  '';

  meta = {
    description = "A CLI tool for querying the J-Quants API V2";
    homepage = "https://github.com/J-Quants/jquants-cli";
    license = lib.licenses.mit;
    mainProgram = "jquants";
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
