{
  pkgs,
  # Callers may pass a patched Node; defaults to the channel's.
  nodejs ? pkgs.nodejs_22,
  ...
}:
with pkgs;
[
  doppler
  fd
  ffmpeg
  fzf
  gh
  jq
  just
  nurl
  ripgrep
  nodejs
  mysql84
  bun
  yt-dlp
]
