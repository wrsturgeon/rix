result: flake.nix
	nix build
	find . -name 'flake.*' | xargs rm

flake.nix: ../../flake.nix.template
	cp $< $@
	git add $@
