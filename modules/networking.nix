{ ... }:

let
  hasIPv6Internet = true;
  StateDirectory = "dnscrypt-proxy";
in
{
  networking.hostName = "nixos";
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
  networking.networkmanager = {
    enable = true;
    dns = "none";
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      server_names = [
        "dnscry.pt-moscow-ipv4"
        "dnscry.pt-moscow-ipv6"
        "dnscry.pt-helsinki-ipv4"
        "dnscry.pt-helsinki-ipv6"
        "quad9-dnscrypt-ip4-filter-pri"
        "quad9-dnscrypt-ip6-filter-pri"
      ];
      ipv6_servers = hasIPv6Internet;
      block_ipv6 = !hasIPv6Internet;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/${StateDirectory}/public-resolvers.md";
      };
    };
  };
  systemd.services.dnscrypt-proxy.serviceConfig.StateDirectory = StateDirectory;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "clash0" ];
  };

  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
  };
}
