{
  home.username = "fern";
  home.homeDirectory = "/home/fern";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  imports = [
    # Shell Programs
    ../modules/shell/tmux.nix
    ../modules/shell/fish.nix
    ../modules/shell/nixvim.nix
    ../modules/shell/git.nix
    ../modules/shell/aria2.nix
    ../modules/shell/misc.nix
    ../modules/shell/nnn.nix
    ../modules/shell/openssh.nix
  ];
}
