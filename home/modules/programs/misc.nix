{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # music
    feishin
    # editors/viewers
    gimp
    sioyek
    imv
    # libreoffice
    libreoffice-still
    hunspell
    hunspellDicts.en_AU
    # chat
    signal-desktop
    fluffychat
    # games
    prismlauncher
    steam-tui
    gamemode
    # virtualisation
    spice
    spice-gtk
    spice-protocol
    virt-viewer
    # misc
    yubioath-flutter
  ];

  # virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
