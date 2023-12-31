#!/usr/bin/env sh

set -eux

nix flake show .
nix flake check .

cd examples
find . -name 'flake.*' | xargs -r rm
for dir in $(find . -type d -mindepth 1 -maxdepth 1)
do
  cd $dir
  make -f ../build.mk
  if [ -f src/main.rs ]
  then
    result/$(echo "$dir" | tr '-' '_')
  fi
  cd ..
done
find . -name 'flake.*' | xargs -r rm
cd ..
