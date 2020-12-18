{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:morpheusthewhite/spicetify-themes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, spicetify-themes }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    make-spicetify = pkgs.callPackage ./package.nix {
      inherit spicetify-themes;
    };
  };
}
