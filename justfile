darwin profile command:
    darwin-rebuild {{ command }} --flake ".#{{profile}}-darwin"
    rm -rf ./result

