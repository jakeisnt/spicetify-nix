{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:morpheusthewhite/spicetify-themes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, spicetify-themes }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      themeNames = [
        "Adapta-Nokto"
        "Arc-Dark"
        "Arc-Green"
        "BIB-Green"
        "Bittersweet"
        "Black"
        "BladeRunner"
        "Blueballs"
        "BreezeLight"
        "BurntSienna"
        "Challenger-Deep"
        "DanDrumStoneNew"
        "Dark"
        "DeepCoral"
        "Discord"
        "Dobbo"
        "Dracula"
        "Dribbblish"
        "DribbblishDynamic"
        "Elementary"
        "Flatten"
        "Gradianto"
        "Gruvbox-Gold"
        "JarvisBot"
        "Kaapi"
        "Material-Ocean"
        "Midnight-Light"
        "MoonChild"
        "Night-Owl"
        "Night"
        "NightMoon"
        "NoSleep"
        "Nord"
        "OneDarkish"
        "Onepunch"
        "Otto"
        "OutrunDark"
        "Phosphoria"
        "Pop-Dark"
        "ShadowCustom"
        "SolarizedDark"
        "Spicy"
        "Sweet"
        "TrekyGoldenrod"
        "Twasi"
        "TychoAwake"
        "Vaporwave"
        "WintergatanBlueprint"
        "YoutubeDark"
      ];
    generatePackages = (ls:
      if ls == [] then {} else nixpkgs.lib.mkMerge [
        {
          ${builtins.head ls} = pkgs.callPackage ./spicetify.nix {
            inherit spicetify-themes;
            themeName = builtins.head ls;
          };
        }
        (generatePackages (builtins.tail ls))
      ]);
    in
    rec {
      packages.x86_64-linux = generatePackages themeNames;
    };
}
