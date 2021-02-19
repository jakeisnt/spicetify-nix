{ pkgs, lib, buildGoModule, fetchFromGitHub, spotify-unwrapped, spicetify-themes }:

let
  spicetify = buildGoModule rec {
    pname = "spicetify-cli";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "khanhas";
      repo = pname;
      rev = "v${version}";
      sha256 = "08rnwj7ggh114n3mhhm8hb8fm1njgb4j6vba3hynp8x1c2ngidff";
    };

    vendorSha256 = "0k06c3jw5z8rw8nk4qf794kyfipylmz6x6l126a2snvwi0lmc601";

    # used at runtime, but not installed by default
    postInstall = ''
      cp -r ${src}/jsHelper $out/bin/jsHelper
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/spicetify-cli --help > /dev/null
    '';

    meta = with lib; {
      description = "Command-line tool to customize Spotify client";
      homepage = "https://github.com/khanhas/spicetify-cli/";
      license = licenses.gpl3Plus;
      maintainers = with maintainers; [ jonringer ];
    };
  };
  spiced = pkgs.stdenv.mkDerivation {
    pname = "spotify-spiced";
    inherit (spotify-unwrapped) version;
    src = pkgs.spotify-unwrapped;
    doUnpackPhase = false;

    phases = [ "unpackPhase" "buildPhase" ];

    buildPhase = ''
      mkdir /tmp/spicetify-config
      export XDG_CONFIG_HOME=/tmp/spicetify-config
      ${spicetify}/bin/spicetify-cli config spotify_path "$(pwd)"/share/spotify
      touch /tmp/spicetify-config/prefs
      ${spicetify}/bin/spicetify-cli config prefs_path /tmp/spicetify-config/prefs
      echo '-------- 1'
      cat $(${spicetify}/bin/spicetify-cli -c)
      echo '-------- 2'
      ls /tmp/spicetify-config/spicetify/Themes
      ls /tmp/spicetify-config/spicetify/Extensions
      mkdir /tmp/spicetify-config/spicetify/Themes/SpicetifyDefault
      cp ${spicetify-themes}/Dribbblish/color.ini /tmp/spicetify-config/spicetify/Themes/SpicetifyDefault/color.ini
      cp ${spicetify-themes}/Dribbblish/user.css /tmp/spicetify-config/spicetify/Themes/SpicetifyDefault/user.css
      cp -r ${spicetify-themes}/Dribbblish/assets /tmp/spicetify-config/spicetify/Themes/SpicetifyDefault/assets
      cp ${spicetify-themes}/Dribbblish/dribbblish.js /tmp/spicetify-config/spicetify/Extensions/dribbblish.js
      ${spicetify}/bin/spicetify-cli config extensions dribbblish.js
      ${spicetify}/bin/spicetify-cli config current_theme SpicetifyDefault color_scheme nord-dark
      ${spicetify}/bin/spicetify-cli config inject_css 1 replace_colors 1 overwrite_assets 1
      echo '-------- 3'
      ${spicetify}/bin/spicetify-cli backup apply
      echo '-------- 4'
      ${spicetify}/bin/spicetify-cli apply
      echo '-------- 5'
      mkdir -p $out
      sed -i "s#${spotify-unwrapped}#$out#g" ./bin/spotify
      cp -r ./* $out
    '';
  };
in pkgs.spotify.override { spotify-unwrapped = spiced; }
