pkgs: name: features:
derivation {
  inherit (pkgs) system;
  inherit name;
  builder = pkgs.rustc;
}
