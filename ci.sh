#!/usr/bin/env sh

set -eux

nix flake show .
nix flake check .

cd examples
for dir in $(find . -type d -mindepth 1 -maxdepth 1)
do
  cd $dir
  make -f ../build.mk
  cd ..
done
cd ..
