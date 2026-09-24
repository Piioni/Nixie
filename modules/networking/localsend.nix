{
  config,
  lib,
  ...
}:
{
  programs.localsend = {
    enable = true;
    openFirewall = false;
  };

  # Limit LocalSend receives to LAN source ranges; this relies on the current iptables backend.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 53317 -s 10.0.0.0/8 -j ACCEPT
    iptables -A nixos-fw -p tcp --dport 53317 -s 172.16.0.0/12 -j ACCEPT
    iptables -A nixos-fw -p tcp --dport 53317 -s 192.168.0.0/16 -j ACCEPT
    iptables -A nixos-fw -p tcp --dport 53317 -s 169.254.0.0/16 -j ACCEPT
    iptables -A nixos-fw -p udp --dport 53317 -s 10.0.0.0/8 -j ACCEPT
    iptables -A nixos-fw -p udp --dport 53317 -s 172.16.0.0/12 -j ACCEPT
    iptables -A nixos-fw -p udp --dport 53317 -s 192.168.0.0/16 -j ACCEPT
    iptables -A nixos-fw -p udp --dport 53317 -s 169.254.0.0/16 -j ACCEPT
  ''
  + lib.optionalString config.networking.enableIPv6 ''
    ip6tables -A nixos-fw -p tcp --dport 53317 -s fc00::/7 -j ACCEPT
    ip6tables -A nixos-fw -p tcp --dport 53317 -s fe80::/10 -j ACCEPT
    ip6tables -A nixos-fw -p udp --dport 53317 -s fc00::/7 -j ACCEPT
    ip6tables -A nixos-fw -p udp --dport 53317 -s fe80::/10 -j ACCEPT
  '';
}
