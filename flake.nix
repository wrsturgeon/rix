{
  description = "Cargo-free Rust builds with Nix.";
  inputs = {
    # woohoo!
  };
  outputs = { self }: {
    crate-with-features = import src/crate-with-features.nix;
    crate = import src/crate.nix;
  };
}
