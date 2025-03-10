{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.firefox;
in
{
  options.${namespace}.apps.firefox = with types; {
    enable = mkBoolOpt false "Enable Firefox browser";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        Containers.Default = [
          {
            name = "Meta";
            color = "blue";
            icon = "fingerprint";
          }
          {
            name = "Shopping";
            color = "orange";
            icon = "cart";
          }
        ];
        Cookies.Behaviour = "reject-tracker-and-partition-foreign";
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePasswordReveal = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Snippets = false;
        };
        Homepage.StartPage = "none";
        EnableTrackingProtection = {
          Value = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };
        ExtensionSettings = {
          "*".installation_mode = "blocked";
          "@testpilot-containers" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            default_area = "navbar";
          };
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            default_area = "menupanel";
          };
          "floccus@handmadeideas.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
            default_area = "menupanel";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            default_area = "navbar";
          };
          "7esoorv3@alefvanoon.anonaddy.me" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi";
            default_area = "menupanel";
          };
          "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
            default_area = "menupanel";
          };
          "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
            default_area = "menupanel";
          };
        };
        NewTabPage = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        Preferences = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = {
            Value = true;
            Status = "default";
            Type = "boolean";
          };
          "browser.compactmode.show" = {
            Value = true;
            Status = "default";
            Type = "boolean";
          };
          "browser.uidensity" = {
            Value = 1;
            Status = "default";
            Type = "number";
          };
          "browser.tabs.inTitlebar" = {
            Value = 0;
            Status = "default";
            Type = "number";
          };
          "places.history.enabled" = {
            Value = false;
            Status = "default";
            Type = "boolean";
          };
        };
        SanitizeOnShutdown = {
          Cache = true;
          History = true;
        };
        ShowHomeButton = false;
      };
      profiles.fern = {
        settings = {
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
        };
        userChrome = ''
          #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
            opacity: 0;
            pointer-events: none;
          }

          #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
              visibility: collapse !important;
          }
        '';
      };
    };
  };
}
