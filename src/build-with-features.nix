pkgs: dir: features:
let
  inherit (pkgs) system;
  cfg = import ./cargo-toml.nix dir features;
  pname = cfg.name;
  version = cfg.version;
  src = if (builtins.readDir dir) ? src then
    "${dir}/src"
  else
    "No `src/` found in the provided directory";
  main = import ./locate-main-file.nix src;
  args-crate = "--crate-name ${pname} --crate-type ${main.type} --edition=2021";
  args-opt = "-C opt-level=3 -C embed-bitcode=no";
in pkgs.stdenv.mkDerivation {
  inherit pname src system version;
  buildPhase = ''
    mkdir -p $out
    ${pkgs.rustc}/bin/rustc ${args-crate} ${main.file} --emit=dep-info,link ${args-opt} --out-dir $out
  '';
}
