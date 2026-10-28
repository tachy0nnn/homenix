{ lib, ... }:

let
  hasIPv6Internet = false;
  StateDirectory = "dnscrypt-proxy";
in
{
  networking.hostName = "nixos";
  networking.nameservers = [
    "127.0.0.1"
  ]
  ++ lib.optional hasIPv6Internet "::1";

  networking.networkmanager = {
    enable = true;
    dns = "none";
    wifi.powersave = false;
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      server_names = [
        "dnscry.pt-moscow-ipv4"
        "dnscry.pt-helsinki-ipv4"
        "quad9-dnscrypt-ip4-filter-pri"
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

  boot.kernelModules = [
    "tcp_bbr"
    "tun"
  ];

  boot.kernel.sysctl = {
    # "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;

    # bbr
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # ref: https://blog.cloudflare.com/optimizing-tcp-for-high-throughput-and-low-latency
    "net.ipv4.tcp_notsent_lowat" = 131072;
    "net.ipv4.tcp_slow_start_after_idle" = 0;

    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 1048576;
    "net.core.wmem_default" = 1048576;
    "net.ipv4.tcp_rmem" = "4096 1048576 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  programs.clash-verge = {
    enable = true;
    tunMode = false;
    serviceMode = true;
  };
}
