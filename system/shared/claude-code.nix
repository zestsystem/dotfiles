# Claude Code portable config: link CLAUDE.md, settings, and skills from this
# repo into ~/.claude as writable out-of-store symlinks, so edits made by
# Claude sessions land in the repo working tree (and get committed + pushed).
# delegation-scorecard.md is intentionally NOT synced: this repo is public and
# the scorecard accumulates work internals — it stays machine-local in ~/.claude.
{ config, ... }:
let
  src = "${config.home.homeDirectory}/.config/claude-code";
  link = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${src}/${path}";
    # replace the hand-made symlinks from the initial setup on first switch
    force = true;
  };
in
{
  home.file.".claude/CLAUDE.md" = link "CLAUDE.md";
  home.file.".claude/settings.json" = link "settings.json";
  home.file.".claude/skills/use-codex" = link "skills/use-codex";
  home.file.".claude/skills/frontend-design" = link "skills/frontend-design";
}
