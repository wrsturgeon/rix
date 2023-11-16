Super simple Cargo project to study its behavior.

Running `cargo build --verbose` shows all (nontrivial) commands Cargo runs.

On my Intel Mac running macOS, it runs (with absolute paths relativized)
```bash
rustc \
--crate-name cargo_lab_rat \
--edition=2021 \
src/main.rs \
--error-format=json \
--json=diagnostic-rendered-ansi,artifacts,future-incompat \
--diagnostic-width=210 \
--crate-type bin \
--emit=dep-info,link \
-C embed-bitcode=no \
-C debuginfo=2 \
-C split-debuginfo=unpacked \
-C metadata=8b6b0bca48c6ee37 \
-C extra-filename=-8b6b0bca48c6ee37 \
--out-dir ./target/debug/deps \
-C incremental=./target/debug/incremental \
-L dependency=./target/debug/deps
```
Odd that `dep.rs` never shows up.

With the default `main.rs` (which adds two numbers) and nothing else, it ran
```bash
rustc \
--crate-name cargo_lab_rat \
--edition=2021 \
src/main.rs \
--error-format=json \
--json=diagnostic-rendered-ansi,artifacts,future-incompat \
--diagnostic-width=210 \
--crate-type bin \
--emit=dep-info,link \
-C embed-bitcode=no \
-C debuginfo=2 \
-C split-debuginfo=unpacked \
-C metadata=8b6b0bca48c6ee37 \
-C extra-filename=-8b6b0bca48c6ee37 \
--out-dir ./target/debug/deps \
-C incremental=./target/debug/incremental \
-L dependency=./target/debug/deps
```
which is literally exactly the same as the above.
So either we're not seeing the call for `dep.rs` or `rustc` is doing more heavy lifting than I thought it was.

Running `cargo build --release --verbose`,
```bash
rustc \
--crate-name cargo_lab_rat \
--edition=2021 \
src/main.rs \
--error-format=json \
--json=diagnostic-rendered-ansi,artifacts,future-incompat \
--diagnostic-width=210 \
--crate-type bin \
--emit=dep-info,link \
-C opt-level=3 \
-C embed-bitcode=no \
-C metadata=f94fdddbec0d03fd \
-C extra-filename=-f94fdddbec0d03fd \
--out-dir ./target/release/deps \
-L dependency=./target/release/deps
```

Here's the output of `diff what-cargo-ran/debug.sh what-cargo-ran/release.sh`:
```diff
9a10
> -C opt-level=3 \
11,17c12,15
< -C debuginfo=2 \
< -C split-debuginfo=unpacked \
< -C metadata=8b6b0bca48c6ee37 \
< -C extra-filename=-8b6b0bca48c6ee37 \
< --out-dir ./target/debug/deps \
< -C incremental=./target/debug/incremental \
< -L dependency=./target/debug/deps
---
> -C metadata=f94fdddbec0d03fd \
> -C extra-filename=-f94fdddbec0d03fd \
> --out-dir ./target/release/deps \
> -L dependency=./target/release/deps
```
So release adds optimization, removes debug info, and that's it, save hash changes or `debug`/`release` directories.

Interesting! So running just `rustc src/main.rs` (with no `target` directory) works and produces a valid executable.
And more interestingly, running `rustc src/dep.rs` fails, citing a lack of `main`.
So `rustc` is (I think pretty clearly) meant to be run on the main file only, but
we'll see if that's literally just `main.rs` or if modules require `rustc mod.rs` as well.
