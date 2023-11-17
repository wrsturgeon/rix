result: flake.nix
	git add -A
	nix build
	rm -f flake.nix flake.lock

flake.nix: ../../flake.nix.template
	cp $^ flake.nix
