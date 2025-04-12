{ lib, ... }:
with lib;
rec {
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };
  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;
  mkBoolOpt' = mkOpt' types.bool;

  mkStrOpt = mkOpt types.str;
  mkStrOpt' = mkOpt' types.str;

  mkPortOpt = mkOpt types.port;
  mkPortOpt' = mkOpt' types.port;

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };

  podmanVolumeDir = "/var/lib/containers/storage/volumes";
  containerDataDir = name: "/var/lib/nixos-containers/${name}";
}
