{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # archive utils
    p7zip
    unrar
    # trash support
    trash-cli
  ];
}
