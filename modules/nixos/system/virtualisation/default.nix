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
  cfg = config.${namespace}.virtualisation;
in
{
  options.${namespace}.virtualisation = with types; {
    qemu.enable = mkBoolOpt false "Enable QEMU";
  };

  config = mkMerge [
    (mkIf cfg.qemu.enable {
      users.users.${config.${namespace}.user.name}.extraGroups = [ "libvirtd" ];
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            swtpm.enable = true;
            ovmf.enable = true;
            ovmf.packages = [ pkgs.OVMFFull.fd ];
          };
        };
        spiceUSBRedirection.enable = true;
      };
      programs.virt-manager.enable = true;

      boot.kernelModules = [ "kvm-intel" ];
    })
  ];
}
