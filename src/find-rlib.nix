dir:
let
  ls = builtins.attrNames (builtins.readDir dir);
  all-rlib = builtins.filter (f:
    let extn = builtins.substring (builtins.stringLength f - 5) 5 f;
    in extn == ".rlib") ls;
in if all-rlib == [ ] then
  throw "No `.rlib` file found in `${dir}`"
else if builtins.length all-rlib > 1 then
  throw "Multiple `.rlib` files found in `${dir}`: ${toString all-rlib}"
else
  "${dir}/${builtins.head all-rlib}"
