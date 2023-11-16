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
