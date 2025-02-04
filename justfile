darwin profile command:
    darwin-rebuild {{ command }} --flake ".#{{profile}}-darwin" --show-trace
    rm -rf ./result

