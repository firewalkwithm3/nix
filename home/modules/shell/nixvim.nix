{ pkgs, ... }:
{
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
}
