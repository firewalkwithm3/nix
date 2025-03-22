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
  cfg = config.${namespace}.cli.nixvim;
in
{
  options.${namespace}.cli.nixvim = with types; {
    enable = mkBoolOpt true "Enable neovim - text editor";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nixfmt-rfc-style ];

    programs.nixvim = {
      enable = true;
      opts = {
        expandtab = true;
        shiftwidth = 2;
        tabstop = 8;
        softtabstop = 2;
      };
      plugins = {
        lsp-format.enable = true;
        lsp = {
          enable = true;
          servers = {
            nixd = {
              enable = true;
              settings.formatting.command = [ "nixfmt" ];
            };
          };
        };
        mini = {
          enable = true;
          modules = {
            comment = { };
            completion = { };
            pairs = { };
            basics = { };
            bracketed = { };
            clue = { };
            diff = { };
            extra = { };
            files = { };
            git = { };
            misc = { };
            pick = { };
            sessions = { };
            cursorword = { };
            hipatterns = { };
            icons = { };
            indentscope = { };
            notify = { };
            statusline = { };
            tabline = { };
            trailspace = { };
          };
        };
      };
    };
  };
}
