_default:
    just --list
darwin profile command:
    sudo darwin-rebuild {{ command }} --flake ".#{{profile}}-darwin" --show-trace
    rm -rf ./result

secrets:
    doppler secrets download --no-file --format env -p mikeyim -c nixos > ~/.env
    @echo "Secrets written to ~/.env"
    @if [ ! -f ~/.ssh/id_ed25519 ]; then \
        mkdir -p ~/.ssh && chmod 700 ~/.ssh; \
        doppler secrets get SSH_PRIVATE_KEY --plain -p mikeyim -c nixos > ~/.ssh/id_ed25519; \
        chmod 600 ~/.ssh/id_ed25519; \
        ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub; \
        ssh-add ~/.ssh/id_ed25519; \
        echo "SSH key bootstrapped"; \
    fi
