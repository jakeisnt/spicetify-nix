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
  in rec {
    packages.x86_64-linux = {
      solarizedDark = pkgs.callPackage ./spicetify.nix {
        inherit spicetify-themes;
      };
    };
  };
}
