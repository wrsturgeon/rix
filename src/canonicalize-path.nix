# <https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html>

let
  recurse = dir: name: info:
    if info ? path then
      if builtins.substring 0 1 info.path == "/" then
        info.path
      else if builtins.substring 0 2 info.path == ".." then
        throw ''
          Paths are not allowed to start with ".." (while parsing dependency `${name}` whose path is `${info.path}`)''
      else
        "${dir}/${info.path}"
    else if info ? git then
      "git+${recurse name { path = info.git; }}"
    else
      "https://crates.io/api/v1/crates/${name}/${info.version}/download";
in recurse
