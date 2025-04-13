{
  channels,
  ...
}:

final: prev: {
  prismlauncher = prev.prismlauncher.override {
    jdks = with channels.nixpkgs; [
      temurin-bin
    ];
  };
}
