explicit-features:
let
  # Imports
  inherit (builtins)
    attrNames concatMap concatStringsSep elemAt filter filterMap getAttr hasAttr
    length listToAttrs partition readFile tail toString trace typeOf;
  concats = concatStringsSep "";
  splitString = # https://github.com/NixOS/nixpkgs/blob/master/lib/strings.nix#L614
    sep: s:
    builtins.filter builtins.isString
    (builtins.split (toString sep) (toString s));

  # Read `Cargo.toml`
  cfg = fromTOML (readFile ./Cargo.toml);

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
  switches = let
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
            throw (concats [
              "Requested feature `"
              (toString feature)
              "`, but no such feature exists"
            ])
          else
            map (name: {
              inherit name;
              value = null;
            }) (getAttr feature available-features)) explicit-features));
  in trace (concats [
    "Your choice of features enabled the following switches: "
    (concatStringsSep ", "
      (map (s: concats [ ''"'' s ''"'' ]) (attrNames enable)))
  ]) enable;

  switched-deps = let
    li = filter (x: x != null) (map (d:
      let splat = splitString ":" d;
      in if length splat > 1 then (concats (tail splat)) else null)
      (attrNames switches));
  in map (x:
    if hasAttr x cfg-dependencies then
      x
    else
      throw (concats [
        "Features enabled the optional dependency `"
        x
        "`, but that dependency was never declared"
      ])) li;

  dependencies = non-optional-deps ++ switched-deps;
in dependencies
