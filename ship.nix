{ pkgs, ... }:

let
  ship = pkgs.writeShellApplication {
    name = "ship";
    runtimeInputs = with pkgs; [
      git
      gh
      coreutils
    ];
    text = ''
      msg="$*"
      if [ -z "$msg" ]; then
        echo 'usage: ship "type(scope): message"' >&2
        exit 1
      fi

      git fetch --quiet origin main
      start=$(git branch --show-current)

      if [ "$start" = main ]; then
        branch="ship/$(date +%m%d-%H%M%S)"
        git switch --quiet --create "$branch"
      else
        branch="$start"
      fi

      untracked=$(git ls-files --others --exclude-standard)
      if [ -n "$untracked" ]; then
        echo "warning: untracked files are NOT included (git add them first):" >&2
        echo "$untracked" >&2
      fi

      if ! git diff --quiet HEAD; then
        git commit --quiet --all --message "$msg"
      fi

      if [ "$(git rev-list --count origin/main..HEAD)" -eq 0 ]; then
        echo "nothing to ship (no changes and no new commits)" >&2
        if [ "$branch" != "$start" ]; then
          git switch --quiet "$start"
          git branch --quiet --delete "$branch"
        fi
        exit 1
      fi

      git push --quiet --set-upstream origin HEAD

      gh pr create --base main --title "$msg" --fill
      gh pr merge --auto --squash || echo "auto-merge failed: enable it in the repo settings, or merge the PR yourself" >&2

      if [ "$start" = main ]; then
        git branch --force main origin/main
      fi
      git switch --quiet main
    '';
  };

  landed = pkgs.writeShellApplication {
    name = "landed";
    runtimeInputs = with pkgs; [
      git
      gawk
      findutils
    ];
    text = ''
      git switch --quiet main
      git pull --quiet --prune
      git branch --verbose --verbose | awk '/: gone]/ { print $1 }' | xargs -r git branch --delete --force
    '';
  };
in
{
  home.packages = [
    ship
    landed
  ];

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
