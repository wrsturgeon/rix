{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rix.url = "../..";
  };
  outputs = { flake-utils, nixpkgs, rix, self }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in { packages.default = rix.build pkgs ./src; });
}
