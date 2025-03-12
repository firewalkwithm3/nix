{
  channels,
  ...
}:

final: prev: {
  inherit (channels.nixpkgs-unstable) nix-search-tv;
}
