{ pkgs, lib, ... }:
{
  systemd.services.lidarr.path = [
    pkgs.beets
  ];

  services.lidarr = {
    enable = true;
    group = "media";
  };

  services.caddy.virtualHosts."lidarr.ferngarden.net" = {
    logFormat = lib.mkForce ''
      output discard
    '';
    extraConfig = ''
      reverse_proxy 127.0.0.1:9000
    '';
  };
}
