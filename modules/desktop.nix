{ pkgs, ... }:

{
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty # mod + t
    fuzzel # mod + d
    swaylock # super + Alt + L
    #waybar # status bar
    xwayland-satellite
    ghostty
  ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-contacts # Contacts
    gnome-weather # Weather
    gnome-clocks # Clocks
    gnome-maps # Maps
    gnome-music # Audio Player
    gnome-calendar # Calendar
    gnome-characters # Characters
    gnome-font-viewer # Fonts
    gnome-connections # Connections
    gnome-software # Software Center
    simple-scan # Document Scanner
    totem # Video Player
    snapshot # Camera
    cheese # Camera fallback
    yelp # Help
    gnome-logs # Logs viewer
    gnome-tour # Welcome Tour
    epiphany # Web
    geary # Email client
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  services.printing.enable = false;
  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
    ];
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.chromium = {
    enable = true;
    extraOpts = {
      #"DnsOverHttpsMode" = "off";
      "WebRtcIPHandling" = "disable_non_proxied_udp";
      "NetworkPredictionOptions" = 2;
      "DNSInterceptionChecksEnabled" = false;
      "BraveAIChatEnabled" = false;
      "BraveLocalAIEnabled" = false;
      "BraveRewardsDisabled" = true;
      "BraveWalletDisabled" = true;
      "BraveTalkDisabled" = true;
      "BraveVPNDisabled" = true;
      "BraveNewsDisabled" = true;
      "TorDisabled" = true;
      "BraveP3AEnabled" = false;
      "BraveStatsPingEnabled" = false;
      "BraveWebDiscoveryEnabled" = false;
      "BraveDeAmpEnabled" = true;
      "BraveDebouncingEnabled" = true;
      "BraveTrackingQueryParametersFilteringEnabled" = true;
      "BraveGlobalPrivacyControlEnabled" = true;
      "BraveReduceLanguageEnabled" = true;
      "MetricsReportingEnabled" = false;
      "UrlKeyedAnonymizedDataCollectionEnabled" = false;
      "SafeBrowsingExtendedReportingEnabled" = false;
      "SpellCheckServiceEnabled" = false;
      "ChromeVariations" = 1;
      "BlockThirdPartyCookies" = true;
      "BrowserSignin" = 0;
      "SyncDisabled" = true;
      "BackgroundModeEnabled" = false;
      "BlockExternalExtensions" = true;
      "DefaultBrowserSettingEnabled" = false;
      "ShoppingListEnabled" = false;
      "AlternateErrorPagesEnabled" = false;
      "BasicAuthOverHttpEnabled" = false;
      "PaymentMethodQueryEnabled" = false;
      "AutofillCreditCardEnabled" = false;
    };
  };
}
