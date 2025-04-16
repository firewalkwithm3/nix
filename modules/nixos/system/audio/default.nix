{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.audio;
in
{
  options.${namespace}.audio = with types; {
    enable = mkBoolOpt config.${namespace}.desktop-environment.enable "Enable pipewire for audio";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      wireplumber.enable = true;
    };

    home-manager.users.${config.${namespace}.user.name}.${namespace}.impermanence.directories = [
      ".local/state/wireplumber"
    ];
  };
}
