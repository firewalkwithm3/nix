{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.home;
in
{
  options.${namespace}.home = with types; {
    enable = mkBoolOpt true "System-wide theming with Stylix";
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      image = pkgs.fetchurl {
        url = "https://images.pexels.com/photos/5418830/pexels-photo-5418830.jpeg?cs=srgb&dl=pexels-elijahsad-5418830.jpg&fm=jpg&w=1920&h=1280";
        sha256 = "sha256-sqvUNJLVhHSawmzCjQ3YjN7OqADeBjSEnqNvCUDZfBk=";
      };
      base16Scheme = {
        slug = "paradise";
        scheme = "Paradise Theme";
        author = "Manas140";
        base00 = "#151515";
        base01 = "#1f1f1f";
        base02 = "#2e2e2e";
        base03 = "#424242";
        base04 = "#bbb6b6";
        base05 = "#e8e3e3";
        base06 = "#e8e3e3";
        base07 = "#e8e3e3";
        base08 = "#b66467";
        base09 = "#b66467";
        base0A = "#d9bc8c";
        base0B = "#8c977d";
        base0C = "#8aa6a2";
        base0D = "#8da3b9";
        base0E = "#a988b0";
        base0F = "#b66467";
      };
      polarity = "dark";
      fonts = {
        monospace = {
          package = pkgs.fira-code-nerdfont;
          name = "FiraCode Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };

        serif = {
          package = pkgs.merriweather;
          name = "Merriweather";
        };

        sansSerif = {
          package = pkgs.fira-sans;
          name = "Fira Sans";
        };

        sizes = {
          applications = 10;
          desktop = 10;
          popups = 10;
          terminal = 10;
        };
      };
      cursor = {
        package = pkgs.simp1e-cursors;
        name = "Simp1e-Dark";
        size = 24;
      };
    };
  };
}
