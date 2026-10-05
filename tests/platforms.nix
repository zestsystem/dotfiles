# Evaluation-only regression tests; fake disks never get built or activated.
# Run: nix eval --impure --json --file tests/platforms.nix
let
  flake = builtins.getFlake (toString ../.);
  linux = flake.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      flake.nixosModules.default
      {
        fileSystems."/" = {
          device = "/dev/test-root";
          fsType = "ext4";
        };
        boot.loader.grub.devices = [ "/dev/test-disk" ];
        system.stateVersion = "26.05";
        zestsystem.username = "laptopuser";
        users.users.laptopuser.hashedPassword = "!";
      }
    ];
  };
  cfg = linux.config;
  home = cfg.home-manager.users.laptopuser;
  settings = builtins.fromJSON home.home.file.".claude/settings.json".text;
  darwin = flake.darwinConfigurations.work-darwin;
  alternate = linux.extendModules {
    modules = [
      {
        services.desktopManager.gnome.enable = false;
        services.displayManager.gdm.enable = false;
        services.power-profiles-daemon.enable = false;
        services.tlp.enable = true;
      }
    ];
  };
in
assert builtins.all (a: a.assertion) cfg.assertions;
assert !(home.programs.zsh.shellAliases ? codex);
assert builtins.elem "codex" (map (p: p.pname or "") home.home.packages);
assert home.home.homeDirectory == "/home/laptopuser";
assert cfg.users.users.laptopuser.hashedPassword == "!";
assert !(cfg.users.users ? mikeyim);
assert cfg.fileSystems."/".device == "/dev/test-root";
assert cfg.system.stateVersion == "26.05";
assert !(settings.hooks ? Notification) && !(settings.hooks ? Stop);
assert settings.hooks.PreToolUse != [ ];
assert
  darwin.config.home-manager.users.mikeyim.programs.zsh.shellAliases.codex
  == "/Applications/ChatGPT.app/Contents/Resources/codex";
assert builtins.all (a: a.assertion) alternate.config.assertions;
{
  linux = cfg.system.build.toplevel.drvPath;
  darwin = darwin.system.drvPath;
  alternate = alternate.config.system.build.toplevel.drvPath;
}
