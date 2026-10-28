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

      untracked=$(git ls-files --others --exclude-standard)
      if [ -n "$untracked" ]; then
        echo "refusing to ship: these files are untracked and would be missing from the PR:" >&2
        echo "$untracked" >&2
        echo "git add them first (or add them to .gitignore), then run ship again." >&2
        exit 1
      fi

      git fetch --quiet origin main
      start=$(git branch --show-current)

      if [ "$start" = main ]; then
        # branch from origin/main: fast-forward local main first; stop if it has diverged
        git merge --quiet --ff-only origin/main || {
            echo "local main can't fast-forward to origin/main; resolve by hand" >&2
            exit 1
        }
        branch="ship/$(date +%m%d-%H%M%S)"
        git switch --quiet --create "$branch"
      else
        branch="$start"
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
      gh
      gawk
      findutils
    ];
    text = ''
      git switch --quiet main
      git pull --quiet --prune

      git branch --format='%(refname:short) %(upstream:track)' \
        | awk '/\[gone\]/ { print $1 }' \
        | while read -r b; do
            merged=$(gh pr list --head "$b" --state merged --json number --jq 'length' 2>/dev/null || echo 0)
            if [ "$merged" -gt 0 ]; then
              echo "deleting $b (its PR was merged)"
              git branch --quiet --delete --force "$b"
            else
              echo "keeping $b: upstream is gone but no merged PR was found. check it by hand." >&2
            fi
          done
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
