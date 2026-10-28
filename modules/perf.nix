# performance tuning, opt-in, revised after the first profile report.
#
# not imported anywhere. to try it:
#   1. copy this file to modules/perf.nix in homenix
#   2. add ./modules/perf.nix to the imports list in configuration.nix
#   3. nh os build, then check the diff with: dix /run/current-system result
#   4. nh os switch only if the build looks right
#
# what changed from the first draft, and why:
#   - vm.swappiness is gone. the report showed 16 GiB available, memory
#     pressure at 0, and only 7.6 MiB of zram in use. nothing to tune yet.
#   - vm.max_map_count is gone. it is already 1048576 and no game here needs
#     more. add it back only if a specific title reports the limit.
#   - the nix build priority stays, because io pressure is the main problem
#     in the report and background builds are a real source of io.
#   - the NetworkManager wait-online delay is new, for boot time.

{ ... }:

{
  # no periodic nmi watchdog wakeups. a small idle-power saving, no downside
  # on a desktop that doesn't use it for debugging.
  boot.kernel.sysctl."kernel.nmi_watchdog" = 0;

  # nix builds (rust, crane, flake checks, gc) run at the lowest cpu and io
  # priority. the report shows io pressure around 85 percent, so keeping
  # background builds from competing with the desktop matters here.
  # note: the io priority only has effect with the bfq io scheduler. the nvme
  # drive currently uses kyber, which largely ignores it [unverified]. the cpu
  # priority still applies either way.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # gamemode raises cpu priority and switches governors only while a game is
  # running. it does nothing during normal use.
  programs.gamemode.enable = true;

  # boot waited about 5.6 seconds for the network to come fully up before
  # starting the graphical session. nothing in this config should need that,
  # but check first: `systemctl list-dependencies --reverse
  # NetworkManager-wait-online.service`. if a unit you care about is listed,
  # keep this service enabled.
  systemd.services.NetworkManager-wait-online.enable = false;
}
