#!/usr/bin/env bash
#
# Kali Linux pentest environment setup
# ------------------------------------
# Usage:
#   ./setup.sh              # runs full setup (doc + tools)
#   ./setup.sh --update     # also run system update/upgrade first
#   TARGET_USER=morty ./setup.sh
#
# Run as the target user with sudo privileges (NOT as root directly).

set -euo pipefail

# ----------------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------------
USER_NAME="${TARGET_USER:-morty}"
USER_HOME="/home/${USER_NAME}"
VENV_DIR="${USER_HOME}/.venvs/MyEnv"
ZSHRC="${USER_HOME}/.zshrc"

DOCS_ROOT="${USER_HOME}/Documents"
HTB_DIR="${DOCS_ROOT}/HackTheBox"
THM_DIR="${DOCS_ROOT}/TryHackMe"
EXPLOIT_DIR="${HTB_DIR}/exploit"

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------
log()  { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[-]\033[0m %s\n' "$*" >&2; exit 1; }

# Append a line to a file only if it isn't already present (idempotent).
append_once() {
    local line="$1" file="$2"
    grep -qsF -- "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

# ----------------------------------------------------------------------
# Pre-flight checks
# ----------------------------------------------------------------------
preflight() {
    [[ $EUID -eq 0 ]] && die "Do not run as root. Run as ${USER_NAME} with sudo access."
    [[ -d "$USER_HOME" ]] || die "Home directory not found: ${USER_HOME}"
    require_cmd sudo
    require_cmd wget
    require_cmd git
    touch "$ZSHRC"
}

# ----------------------------------------------------------------------
# System update / upgrade (optional — pass --update)
# ----------------------------------------------------------------------
update() {
    log "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y \
        python3 python3-pip python3-dev python3-venv \
        git libssl-dev libffi-dev build-essential
}

# ----------------------------------------------------------------------
# Dotfiles (aliases, zshrc hooks, vimrc)
# ----------------------------------------------------------------------
dotfiles() {
    log "Fetching dotfiles..."
    wget -q "https://raw.githubusercontent.com/3nhj0/conf_files/main/.zsh_aliases" \
        -O "${USER_HOME}/.zsh_aliases"
    wget -q "https://raw.githubusercontent.com/3nhj0/conf_files/main/.vimrc" \
        -O "${USER_HOME}/.vimrc"

    log "Configuring ${ZSHRC}..."
    append_once "source ${VENV_DIR}/bin/activate" "$ZSHRC"
    # Note: $PATH is single-quoted so it stays literal in the file.
    append_once 'export PATH=$HOME/.local/bin:$PATH' "$ZSHRC"

    # Source aliases if present (written as a literal multi-line block).
    if ! grep -qsF '.zsh_aliases' "$ZSHRC"; then
        cat >> "$ZSHRC" <<'EOF'
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
EOF
    fi
}

# ----------------------------------------------------------------------
# Directory scaffold + tooling downloads
# ----------------------------------------------------------------------
doc() {
    log "Creating working directories..."
    mkdir -p "${HTB_DIR}/.env" \
             "${THM_DIR}/.env" \
             "${EXPLOIT_DIR}" \
             "${USER_HOME}/ghidra"

    log "Downloading linPEAS..."
    wget -q "https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh" \
        -O "${EXPLOIT_DIR}/linpeas.sh"
    chmod +x "${EXPLOIT_DIR}/linpeas.sh"
}

# ----------------------------------------------------------------------
# Tooling
# ----------------------------------------------------------------------
tools() {
    log "Installing APT packages..."
    sudo apt-get install -y \
        zsh gdb gobuster dirsearch \
        docker.io docker-compose

    log "Installing ropper (pip package, not in APT)..."
    # ropper is installed into the venv below alongside pwntools.

    log "Installing Ghidra via snap..."
    if command -v snap >/dev/null 2>&1; then
        sudo snap install ghidra || warn "Ghidra snap install failed — install manually."
    else
        warn "snap not available — skipping Ghidra."
    fi

    # --- Docker access ---
    # Preferred: add user to the docker group (still root-equivalent, but the
    # standard approach). Log out / back in for group membership to take effect.
    log "Adding ${USER_NAME} to the docker group..."
    sudo usermod -aG docker "${USER_NAME}"

    # --- Python venv + pwntools + ropper ---
    log "Setting up Python virtualenv and pwntools..."
    mkdir -p "$(dirname "$VENV_DIR")"
    [[ -d "$VENV_DIR" ]] || python3 -m venv "$VENV_DIR"
    # shellcheck disable=SC1091
    source "${VENV_DIR}/bin/activate"
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade pwntools ropper
    deactivate

    # --- pwndbg (clone once, run setup as the user, not root) ---
    if [[ ! -d "${USER_HOME}/pwndbg/.git" ]]; then
        log "Cloning pwndbg..."
        git clone https://github.com/pwndbg/pwndbg.git "${USER_HOME}/pwndbg"
    else
        log "pwndbg already present — pulling latest..."
        git -C "${USER_HOME}/pwndbg" pull --ff-only || warn "pwndbg pull failed."
    fi
    log "Running pwndbg setup..."
    bash "${USER_HOME}/pwndbg/setup.sh"
}

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
main() {
    preflight

    if [[ "${1:-}" == "--update" ]]; then
        update
    fi

    dotfiles
    doc
    tools

    log "Changing default shell to zsh..."
    chsh -s "$(command -v zsh)" "${USER_NAME}" || \
        warn "chsh failed — change your shell manually with: chsh -s \$(which zsh)"

    log "Done. Open a new terminal (or log out/in) to load the new shell and docker group."
}

main "$@"
