name:
let
  inherit (builtins) concatStringsSep genList stringLength substring;
  concat = concatStringsSep "";
  chars = s: genList (i: substring i 1 s) (stringLength s);
in concat (map (c: if c == "-" then "_" else c) (chars name))
