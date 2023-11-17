src:
let
  ls = builtins.readDir src;
  found = builtins.trace src (if ls ? "lib.rs" then
    "${src}/lib.rs"
  else if ls ? "main.rs" then
    "${src}/main.rs"
  else
    throw
    "Neither `lib.rs` nor `main.rs` found in the provided `src/`. Found only [${
      toString (builtins.attrNames ls)
    }].");
in builtins.trace found found
