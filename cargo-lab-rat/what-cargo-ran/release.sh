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
