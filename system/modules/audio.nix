{
  # Pipewire
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };
}
