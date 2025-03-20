{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.fish;
in
{
  options.${namespace}.cli.fish = with types; {
    enable = mkBoolOpt false "Enable fish shell";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.fish = {
        enable = true;
        functions = {
          fish_greeting = "";
          nrs = "nixos-rebuild switch --use-remote-sudo --flake /home/fern/git/nix";
          nrt = "nixos-rebuild test --use-remote-sudo --flake /home/fern/git/nix";
          nrb = "nixos-rebuild build --use-remote-sudo --flake /home/fern/git/nix";
          nrbt = "nixos-rebuild boot --use-remote-sudo --flake /home/fern/git/nix";
        };
      };
    }

    (mkIf config.${namespace}.cli.nixvim.enable {
      programs.fish.interactiveShellInit = ''
        set -gx EDITOR 'nvim'
      '';
    })

    (mkIf config.${namespace}.cli.caligula.enable {
      programs.fish.functions.burn = ''
        caligula burn \
          --compression auto \
          --hash skip \
          --force \
          --root always \
          $argv
      '';
    })

    (mkIf config.${namespace}.cli.nnn.enable {
      programs.fish = {
        interactiveShellInit = ''
          set -gx NNN_FCOLORS "070704020003030101060607"
          set -gx NNN_OPTS 'a'
          set -gx NNN_TRASH '1'
        '';

        functions.n = ''
          # Block nesting of nnn in subshells
          if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
              echo "nnn is already running"
              return
          end

          # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
          # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
          # see. To cd on quit only on ^G, remove the "-x" from both lines below,
          # without changing the paths.
          if test -n "$XDG_CONFIG_HOME"
              set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
          else
              set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
          end

          # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
          # stty start undef
          # stty stop undef
          # stty lwrap undef
          # stty lnext undef

          # The command function allows one to alias this function to `nnn` without
          # making an infinitely recursive alias
          command nnn $argv

          if test -e $NNN_TMPFILE
              source $NNN_TMPFILE
              rm $NNN_TMPFILE
          end
        '';
      };
    })

    (mkIf config.${namespace}.apps.kitty.enable {
      programs.fish.functions.s = ''
        kitten ssh $argv
      '';
    })

    (mkIf config.${namespace}.cli.rsync.enable {
      programs.fish.functions.rs = "rsync --archive --progress --human-readable --verbose $argv";
    })
  ]);
}
