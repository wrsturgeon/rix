src:
let ls = builtins.readDir src;
in if ls ? "lib.rs" then {
  file = "${src}/lib.rs";
  type = "lib";
} else if ls ? "main.rs" then {
  file = "${src}/main.rs";
  type = "bin";
} else
  throw
  "Neither `lib.rs` nor `main.rs` found in the provided `src/`. Found only [${
    toString (builtins.attrNames ls)
  }]."
