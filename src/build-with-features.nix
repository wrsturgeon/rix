pkgs: src: features:
let
  inherit (pkgs) system;
  cfg = import ./cargo-toml.nix features;
  pname = cfg.name;
  version = cfg.version;
  args-crate = "--crate-name ${pname} --crate-type bin --edition=2021";
  args-opt = "-C opt-level=3 -C embed-bitcode=no";
  main = import ./locate-main-file.nix src;
in pkgs.stdenv.mkDerivation {
  inherit pname src system version;
  buildPhase = ''
    mkdir -p $out
    ${pkgs.rustc}/bin/rustc ${args-crate} ${main} --emit=dep-info,link ${args-opt} --out-dir $out
  '';
}
