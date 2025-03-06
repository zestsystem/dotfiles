{ inputs }:
{ pkgs, ... }:
let
  catppuccin-bat = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "bat";
    rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
    sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
  };
  isDarwin = pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-darwin";
  system = pkgs.system;
  vim-just = pkgs.vimUtils.buildVimPlugin {
    name = "vim-just";
    nativeBuildInputs = with pkgs; [
      pkg-config
      readline
    ];
    src = pkgs.fetchFromGitHub {
      owner = "NoahTheDuke";
      repo = "vim-just";
      rev = "927b41825b9cd07a40fc15b4c68635c4b36fa923";
      sha256 = "sha256-BmxYWUVBzTowH68eWNrQKV1fNN9d1hRuCnXqbEagRoY=";
    };
  };
  zsh-z = pkgs.fetchFromGitHub {
    owner = "agkozak";
    repo = "zsh-z";
    rev = "da8dee3ccaf882d1bf653c34850041025616ceb5";
    sha256 = "sha256-MHb9Q7mwgWAs99vom6a2aODB40I9JTBaJnbvTYbMwiA=";
  };
in
{
  #---------------------------------------------------------------------
  # home
  #---------------------------------------------------------------------

  home.sessionVariables = {
    CHARM_HOST = "localhost";
    EDITOR = "nvim";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    PATH = "$PATH:$GOPATH/bin";
    PULUMI_K8S_SUPPRESS_HELM_HOOK_WARNINGS = "true";
    PULUMI_SKIP_UPDATE_CHECK = "true";
  };

  home.stateVersion = "23.11";

  #---------------------------------------------------------------------
  # programs
  #---------------------------------------------------------------------

  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin";
    };
    themes = {
      catppuccin = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
      };
    };
  };

  programs.bottom.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.startup.homepage" = "https://searx.aicampground.com";
          "browser.search.defaultenginename" = "Searx";
          "browser.search.order.1" = "Searx";
        };
        search = {
          force = true;
          default = "Searx";
          order = [
            "Searx"
            "Google"
          ];
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "Searx" = {
              urls = [ { template = "https://searx.aicampground.com/?q={searchTerms}"; } ];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@searx" ];
            };
            "Bing".metaData.hidden = true;
            "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        bookmarks = [
          {
            name = "UTC";
            toolbar = true;
            bookmarks = [
              {
                name = "AWS Dashboard";
                url = "https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2";
              }
              {
                name = "Baselime Console";
                url = "https://console.baselime.io/utc/prod/default/home";
              }
              {
                name = "Cloudflare Dashboard";
                url = "https://dash.cloudflare.com/f7539e9c233bad18f447ee28011bacc8";
              }
              {
                name = "Doppler Workplace";
                url = "https://dashboard.doppler.com/workplace/01b054739b7daf4fb835/projects";
              }
              {
                name = "Redpanda Dashboard";
                url = "https://cloud.redpanda.com/clusters";
              }
              {
                name = "Stripe Dashboard";
                url = "https://dashboard.stripe.com/dashboard";
              }
              {
                name = "Apple Developer";
                url = "https://developer.apple.com/account";
              }
              {
                name = "Google Cloud Console";
                url = "https://console.cloud.google.com/welcome?authuser=1&inv=1&invt=AbjgdQ&project=utc-app-328309";
              }
              {
                name = "Google Play Console";
                url = "https://play.google.com/console/u/1/developers/6440705807370764741/app-list";
              }
              {
                name = "Banking - Mercury";
                url = "https://app.mercury.com/dashboard";
              }
              {
                name = "Legal - Delawareinc";
                url = "https://mcd.delawareinc.com/home";
              }
            ];
          }
          {
            name = "Github";
            url = "https://github.com";
          }
          {
            name = "ChatGPT";
            url = "https://chatgpt.com";
          }
          {
            name = "Fun";
            toolbar = true;
            bookmarks = [
              {
                name = "YouTube";
                url = "https://youtube.com";
              }
              {
                name = "Anime";
                url = "https://hianime.to/";
              }
              {
                name = "Sports Surge - MMA";
                url = "https://v3.sportsurge.to/mmastreams9";
              }
            ];
          }
        ];
      };
    };
  };

  programs.go = {
    enable = true;
    goPath = "Development/language/go";
  };

  programs.git = {
    delta = {
      enable = true;
      options = {
        chameleon = {
          dark = true;
          line-numbers = true;
          side-by-side = true;
          keep-plus-minus-markers = true;
          syntax-theme = "Nord";
          file-style = "#434C5E bold";
          file-decoration-style = "#434C5E ul";
          file-added-label = "[+]";
          file-copied-label = "[==]";
          file-modified-label = "[*]";
          file-removed-label = "[-]";
          file-renamed-label = "[->]";
          hunk-header-style = "omit";
          line-numbers-left-format = " {nm:>1} │";
          line-numbers-left-style = "red";
          line-numbers-right-format = " {np:>1} │";
          line-numbers-right-style = "green";
          line-numbers-minus-style = "red italic black";
          line-numbers-plus-style = "green italic black";
          line-numbers-zero-style = "#434C5E italic";
          minus-style = "bold red";
          minus-emph-style = "bold red";
          plus-style = "bold green";
          plus-emph-style = "bold green";
          zero-style = "syntax";
          blame-code-style = "syntax";
          blame-format = "{author:<18} ({commit:>7}) {timestamp:^12} ";
          blame-palette = "#2E3440 #3B4252 #434C5E #4C566A";
        };
        features = "chameleon";
        side-by-side = true;
      };
    };

    enable = true;
    userEmail = "mk337337@gmail.com";
    userName = "zestsystem";

    extraConfig = {
      color.ui = true;
      diff.colorMoved = "zebra";
      fetch.prune = true;
      github.user = "zestsystem";
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      push.autoSetupRemote = true;
      rebase.autoStash = true;
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      foreground = "#CAD3F5";
      background = "#0F0015";
      selection_foreground = "#24273A";
      selection_background = "#F4DBD6";
      cursor = "#F4DBD6";
      cursor_text_color = "#24273A";
      url_color = "#F4DBD6";
      active_border_color = "#B7BDF8";
      inactive_border_color = "#6E738D";
      bell_border_color = "#EED49F";
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";
      active_tab_foreground = "#181926";
      active_tab_background = "#C6A0F6";
      inactive_tab_foreground = "#CAD3F5";
      inactive_tab_background = "#1E2030";
      tab_bar_background = "#181926";
      mark1_foreground = "#24273A";
      mark1_background = "#B7BDF8";
      mark2_foreground = "#24273A";
      mark2_background = "#C6A0F6";
      mark3_foreground = "#24273A";
      mark3_background = "#7DC4E4";
      color0 = "#494D64";
      color8 = "#5B6078";
      color1 = "#ED8796";
      color9 = "#ED8796";
      color2 = "#A6DA95";
      color10 = "#A6DA95";
      color3 = "#EED49F";
      color11 = "#EED49F";
      color4 = "#8AADF4";
      color12 = "#8AADF4";
      color5 = "#F5BDE6";
      color13 = "#F5BDE6";
      color6 = "#8BD5CA";
      color14 = "#8BD5CA";
      color7 = "#B8C0E0";
      color15 = "#A5ADCB";
      background_opacity = "0.9";
      font_size = "15";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      enabled_layouts = "splits";
    };
    theme = "Catppuccin-Macchiato";
  };

  programs.neovim = inputs.zestsystem-nvim.lib.mkHomeManager { inherit system; };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -a terminal-overrides ",*256col*:RGB"

      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # Change prefix from 'Ctrl+B' to 'Ctrl+A'
      unbind C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix
    '';
    plugins = with pkgs; [
      customTmux.catppuccin
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.sessionist
      tmuxPlugins.yank
      tmuxPlugins.tmux-fzf
      tmuxPlugins.tilish
    ];
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = if isDarwin then "screen-256color" else "xterm-256color";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      cat = "bat";
      wt = "git worktree";
      # aider watch mode
      gemini = "aider --watch-files --model gemini/gemini-2.0-flash";
      mini = "aider --watch-files --mini";
      sonnet = "aider --watch-files --sonnet";
    };

    plugins = [
      {
        name = "zsh-z";
        src = zsh-z;
      }
    ];

    initExtra = ''
      if [ "$TMUX" = "" ]; then tmux a || tmux new; fi

      bindkey -s '^f' 'tmux neww tmux-sessionizer^M'


      # Load environment variables from a file; this approach allows me to not
      # commit secrets like API keys to Git
      if [ -e ~/.env ]; then
        . ~/.env
      fi
    '';
  };
}
