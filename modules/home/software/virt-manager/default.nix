{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.virt-manager;
in
{
  options.${namespace}.apps.virt-manager = with types; {
    enable = mkBoolOpt false "Enable virt-manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      spice
      spice-gtk
      spice-protocol
      virt-viewer
    ];

    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
