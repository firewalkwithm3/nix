{ config, ... }:
let
  hostName = config.networking.hostName;
in
{
  # Immutable users
  users.mutableUsers = false;

  # User password
  age.secrets."user_${hostName}".rekeyFile = ../../../secrets/users/${hostName}.age;
  users.users.fern.hashedPasswordFile = config.age.secrets."user_${hostName}".path;

  # Single user system
  users.users.fern = {
    isNormalUser = true;
    description = "Fern Garden";
    createHome = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
  };
}
