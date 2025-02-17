{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Enable Yubikey support
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ];

  services.pcscd.enable = true;

  # Yubikey integrations
  security.pam.services = {
    sudo.rules.auth = {
      unix.control = lib.mkForce "sufficient";
      u2f = {
        order = config.security.pam.services.sudo.rules.auth.unix.order - 10;
        control = lib.mkForce "sufficient";
        args = [ "pinverification=1" ];
      };
    };
    login.rules.auth = {
      unix.control = lib.mkForce "requisite";
      u2f = {
        order = config.security.pam.services.login.rules.auth.unix.order + 10;
        control = lib.mkForce "sufficient";
      };
    };
    gdm-password.rules.auth = {
      unix.control = lib.mkForce "requisite";
      u2f = {
        order = config.security.pam.services.gdm-password.rules.auth.unix.order + 10;
        control = lib.mkForce "sufficient";
      };
    };
    gtklock.rules.auth = {
      unix.control = lib.mkForce "requisite";
      u2f = {
        order = config.security.pam.services.gtklock.rules.auth.unix.order + 10;
        control = lib.mkForce "sufficient";
      };
    };
  };

  age.secrets.u2f_keys = {
    rekeyFile = ../../secrets/u2f_keys.age;
    owner = "fern";
  };

  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;
      authfile = config.age.secrets.u2f_keys.path;
      origin = "fern";
    };
  };
}
