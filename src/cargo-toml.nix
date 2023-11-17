dir: explicit-features:
let
  # Imports
  inherit (builtins)
    attrNames concatMap concatStringsSep filter getAttr hasAttr length
    listToAttrs readDir readFile tail toString;
  concats = concatStringsSep "";
  splitString = # https://github.com/NixOS/nixpkgs/blob/master/lib/strings.nix#L614
    sep: s:
    builtins.filter builtins.isString
    (builtins.split (toString sep) (toString s));

  # Read `Cargo.toml`
  ls = readDir dir;
  cargo-dot-toml = if ls ? "Cargo.toml" then
    "${dir}/Cargo.toml"
  else
    throw
    "No `Cargo.toml` found in the provided directory. Here's what was found: [${
      toString (attrNames ls)
    }]";
  cfg = fromTOML (readFile cargo-dot-toml);
  cfg-package = if cfg ? package then
    cfg.package
  else
    throw "No `[package]` section in `Cargo.toml`";
  pkg-name = if cfg-package ? name then
    import ./canonicalize-names.nix cfg-package.name
  else
    throw "No `name` field under `[package]` in `Cargo.toml`";

  # Standardized log message tagged with the crate name
  log = msg: val: builtins.trace "(in crate ${pkg-name}) ${msg}" val;

  # If features were specified, use them; otherwise, use an empty set
  available-features = if cfg ? features then cfg.features else { };

  # Look up dependencies
  cfg-dependencies = if cfg ? dependencies then cfg.dependencies else { };
  dep-names = attrNames cfg-dependencies;
  dep-info = name: getAttr name cfg-dependencies;
  non-optional = name:
    let value = dep-info name;
    in if value ? optional then !value.optional else true;
  non-optional-deps = filter non-optional dep-names;

  # Look up implications of features and store as a set mapping each feature name to `null`
  all-switches = let
    enable = if explicit-features == null then
      ( # Use `default` if no features specified, and use an empty list if no default specified
        if available-features ? default then
          available-features.default
        else
          { })
    else
      ( # Assert that all features actually exist
        listToAttrs (concatMap (feature:
          if !(hasAttr feature available-features) then
            throw "Requested feature `${
              toString feature
            }`, but no such feature exists"
          else
            map (name: {
              inherit name;
              value = null;
            }) (getAttr feature available-features)) explicit-features));
  in log "Your choice of features enabled the following switches: ${
    concatStringsSep ", " (map (s: ''"${s}"'') (attrNames enable))
  }" enable;

  # Find all dependencies enabled by features
  switched-deps = let
    li = filter (x: x != null) (map (d:
      let splat = splitString ":" d;
      in if length splat > 1 then (concats (tail splat)) else null)
      (attrNames all-switches));
  in map (x:
    if hasAttr x cfg-dependencies then
      x
    else
      throw
      "`${pkg-name}`: Features enabled the optional dependency `${x}`, but that dependency was never declared")
  li;

  dependencies = let
    deps = listToAttrs (map (name: {
      inherit name;
      value = getAttr name cfg-dependencies;
    }) (non-optional-deps ++ switched-deps));
  in log "All enabled dependencies: ${concatStringsSep ", " (attrNames deps)}"
  deps;
in {
  name = pkg-name;
  inherit (cfg.package) version;
  inherit dependencies;
}
