{
  description = "NixOS Systems Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey/1a30818e41b6573389abfe4f1f99086714c0ca6a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-24.11";

    crowdsec = {
      url = "git+https://codeberg.org/kampka/nix-flake-crowdsec.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    authentik-nix.url = "github:nix-community/authentik-nix";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;
      snowfall.namespace = "flock";

      ### CHANNEL CONFIG ###
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "fluffychat-linux-1.22.1"
          "olm-3.2.16"
          "dotnet-sdk-6.0.136"
          "dotnet-runtime-6.0.36"
        ];
      };

      ### MODULES ###
      systems.modules.nixos = with inputs; [
        agenix-rekey.nixosModules.default
        agenix.nixosModules.default
        authentik-nix.nixosModules.default
        auto-cpufreq.nixosModules.default
        crowdsec.nixosModules.crowdsec
        crowdsec.nixosModules.crowdsec-firewall-bouncer
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        lanzaboote.nixosModules.lanzaboote
        stylix.nixosModules.stylix
        simple-nixos-mailserver.nixosModule
      ];

      systems.hosts.weebill.modules = with inputs; [
        nixos-hardware.nixosModules.raspberry-pi-4
      ];

      homes.modules = with inputs; [
        niri.homeModules.niri
        niri.homeModules.stylix
        nixvim.homeManagerModules.nixvim
      ];

      ### OVERLAYS ###
      overlays = with inputs; [
        agenix-rekey.overlays.default
        crowdsec.overlays.default
        snowfall-flake.overlays.default
      ];

      ### TEMPLATES ###
      templates = {
        modules.description = "Create a module";
        systems.description = "Configure a host";
        homes.description = "Create a new home config";
        services.description = "Create a service behind a reverse proxy";
      };

      ### EXTRA CONFIG ###
      agenix-rekey =
        with inputs;
        agenix-rekey.configure {
          userFlake = self;
          nixosConfigurations = self.nixosConfigurations;
        };
    };
}
