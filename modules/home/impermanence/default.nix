{
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
{
  options.${namespace}.impermanence = with types; {
    directories = mkOpt (listOf str) [ ] "List of home directories to persist";
    files = mkOpt (listOf str) [ ] "List of home files to persist";
  };
}
