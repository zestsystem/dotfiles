_default:
    just --list
darwin profile command:
    sudo darwin-rebuild {{ command }} --flake ".#{{profile}}-darwin" --show-trace
    rm -rf ./result
