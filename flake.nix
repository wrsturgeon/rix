{
  description = "Cargo-free Rust builds with Nix.";
  inputs = {
    # woohoo!
  };
  outputs = { self }: {
    build-with-features = import src/build-with-features.nix;
    build = import src/build.nix;
    crate = import src/crate.nix;
  };
}
