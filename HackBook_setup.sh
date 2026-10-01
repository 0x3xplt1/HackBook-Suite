#!/bin/bash

# HackBook Suite — macOS Penetration Testing Setup
# Transforms a fresh macOS installation into a cybersecurity and penetration testing environment.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
#  ASCII ART BANNER
# ============================================================
cat << 'EOF'

  ██╗  ██╗ █████╗  ██████╗██╗  ██╗██████╗  ██████╗  ██████╗ ██╗  ██╗
  ██║  ██║██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗██╔═══██╗██║ ██╔╝
  ███████║███████║██║     █████╔╝ ██████╔╝██║   ██║██║   ██║█████╔╝
  ██╔══██║██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║   ██║██╔═██╗
  ██║  ██║██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝╚██████╔╝██║  ██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝

                 macOS Cybersecurity Toolkit Setup
          Turning your Mac into a Hacking Machine since 2026
EOF

echo ""
echo "============================================================"
echo "  Starting HackBook Setup — $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"
echo ""

# ============================================================
#  SECTION 0 — PRE-FLIGHT CHECKS
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [0] PRE-FLIGHT CHECKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 0.1 Rosetta 2 (Apple Silicon)
if [ "$(uname -m)" = "arm64" ]; then
    echo "[*] Apple Silicon (ARM64) detected."
    if ! pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
        echo "[*] Installing Rosetta 2..."
        softwareupdate --install-rosetta --agree-to-license || true
    else
        echo "[+] Rosetta 2 already installed."
    fi
fi

# 0.2 Gatekeeper / App Quarantine Notice
echo ""
echo "[*] Gatekeeper Note:"
echo "    Modern macOS (14+) restricts disabling Gatekeeper globally."
echo "    We have added a custom 'unquarantine' command to your terminal."
echo "    If an app is blocked, simply run: unquarantine /Applications/AppName.app"

# 0.3 macOS Permissions Warning
echo ""
echo "[!] IMPORTANT: macOS Privacy & Security"
echo "    During installation, macOS might ask to grant Terminal permissions"
echo "    (e.g., 'App Management' or 'System Events') to configure apps like xbar."
echo "    Please click 'Allow' or 'OK' if prompted."
read -rp "    Press [Enter] to acknowledge and continue..."

# 0.3 Directory Selection
echo ""
if [ -d "$HOME/Documents/Tools" ]; then
    SELECTED_TOOLS_DIR="$HOME/Documents/Tools"
    echo "[*] Existing Tools folder detected: $SELECTED_TOOLS_DIR"
elif [ -d "$HOME/Tools" ]; then
    SELECTED_TOOLS_DIR="$HOME/Tools"
    echo "[*] Existing Tools folder detected: $SELECTED_TOOLS_DIR"
else
    echo "[?] Where should Tools & Wordlists be installed?"
    echo "    1) ~/Tools          [Local – does NOT sync to iCloud]  <- Recommended"
    echo "    2) ~/Documents/Tools [Syncs ~3-5GB to iCloud if enabled]"
    read -rp "    Select [1/2] (Default: 1): " dir_choice
    [ "$dir_choice" = "2" ] && SELECTED_TOOLS_DIR="$HOME/Documents/Tools" || SELECTED_TOOLS_DIR="$HOME/Tools"
    echo "[+] Selected: $SELECTED_TOOLS_DIR"
fi

# ============================================================
#  SECTION 1 — HOMEBREW
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [1] HOMEBREW"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if ! command -v brew &>/dev/null; then
    echo "[*] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "[+] Homebrew already installed."
fi

if [ "$(uname -m)" = "arm64" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix)"

echo "[*] Updating Homebrew..."
brew update

# ============================================================
#  SECTION 2 — CORE TOOLS & BUILD ESSENTIALS
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [2] CORE TOOLS & BUILD ESSENTIALS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

brew install coreutils curl git grep nano wget tmux jq tree cmake libxml2 libxslt

# ============================================================
#  SECTION 3 — PYTHON (pyenv)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [3] PYTHON via pyenv"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

brew install pyenv openssl readline sqlite3 xz zlib tcl-tk bzip2 openjdk

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

echo "[*] Compiling Python versions via pyenv (this may take a while)..."
PYTHON_VERSIONS=("3.10.16" "3.12.9" "3.13.2" "3.14.0")

for v in "${PYTHON_VERSIONS[@]}"; do
    AR=/usr/bin/ar RANLIB=/usr/bin/ranlib pyenv install -s "$v" >/dev/null 2>&1 &
    PID=$!
    spin="."
    while kill -0 $PID 2>/dev/null; do
        printf "\r[+] Installing Python %s (compiling%-3s)" "$v" "$spin"
        [ "$spin" = "..." ] && spin="." || spin="$spin."
        sleep 1
    done
    wait $PID && echo -e "\r[+] Python $v -> Done!   " || echo -e "\r[-] Python $v -> Failed  "
done

pyenv global 3.14.0 3.13.2 3.12.9 3.10.16

# ============================================================
#  SECTION 4 — PIPX
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [4] PIPX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

brew install pipx || true
brew link --overwrite pipx 2>/dev/null || true
pipx ensurepath
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set pipx to use a path without spaces (avoids "bad interpreter" on macOS)
# and default to Python 3.10 (most compatible with hacking tools)
export PIPX_HOME="$HOME/.local/pipx"
export PIPX_DEFAULT_PYTHON="$HOME/.pyenv/versions/3.10.16/bin/python3"

# ============================================================
#  SECTION 5 — CLI TOOLS (Homebrew)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [5] CLI PENTESTING TOOLS (Homebrew)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

export HOMEBREW_NO_AUTO_UPDATE=1

# Note: ffuf and gobuster installed via go install (Section 9)
BREW_TOOLS=(
    nmap masscan hydra john-jumbo hashcat netcat socat openvpn aircrack-ng
    crunch massdns nikto theharvester sqlcmd freerdp inetutils
    amass exiftool exploitdb dnsmap samba swaks sevenzip iproute2mac
    go rust ruby php maven mariadb redis poetry gh ripgrep htop vnstat
    watch rlwrap gnu-sed proxychains-ng binutils
)

for tool in "${BREW_TOOLS[@]}"; do
    rm -f ~/bin/$tool 2>/dev/null || true
    brew install "$tool" || true
    brew link --overwrite "$tool" 2>/dev/null || true
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [5.5] REVERSE ENGINEERING, CLOUD & OSINT TOOLS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DEV_TOOLS=(
    binwalk apktool jadx ghidra awscli azure-cli powershell sigrok-cli micropython spim
    node deno rbenv tesseract yt-dlp speedtest-cli
)

for tool in "${DEV_TOOLS[@]}"; do
    brew install "$tool" || echo "[-] Failed: $tool"
done

unset HOMEBREW_NO_AUTO_UPDATE

# ============================================================
#  SECTION 6 — DIRECTORIES & ASSETS
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [6] DIRECTORY SETUP & ASSETS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p ~/bin ~/DockerLabs/docker-shared-data "$SELECTED_TOOLS_DIR"

# Docker blueprints
if [ -d "$SCRIPT_DIR/docker" ]; then
    cp -r "$SCRIPT_DIR/docker/kali-linux-lab" ~/DockerLabs/ 2>/dev/null || true
    cp -r "$SCRIPT_DIR/docker/parrot-os-lab" ~/DockerLabs/ 2>/dev/null || true
fi

# Mars4_5.jar — MIPS Simulator (for 'mars' alias in .zshrc)
mkdir -p "$SELECTED_TOOLS_DIR/mars"
if [ -f "$SCRIPT_DIR/assets/Mars4_5.jar" ]; then
    cp "$SCRIPT_DIR/assets/Mars4_5.jar" "$SELECTED_TOOLS_DIR/mars/Mars4_5.jar"
    echo "[+] Mars4_5.jar installed to $SELECTED_TOOLS_DIR/mars/"
else
    echo "[-] Mars4_5.jar not found in $SCRIPT_DIR/assets/ — copy it manually to $SELECTED_TOOLS_DIR/mars/"
fi

echo "[+] Directories ready."

# ============================================================
#  SECTION 7 — PYTHON HACKING TOOLS (pipx)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [7] PYTHON HACKING TOOLS (pipx)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PIPX_TOOLS=(
    impacket
    smbmap
    ldapdomaindump
    donpapi
    certipy-ad
    droopescan
    lsassy
    masky
    minikerberos
    pwntools
    pypykatz
    shodan
    ssh-audit
    wafw00f
    censys
    sqlmap
    mycli
    pgcli
    litecli
    fierce
    oletools
    xortool
    h8mail
)

for tool in "${PIPX_TOOLS[@]}"; do
    echo "[+] pipx install $tool"
    rm -f ~/bin/$tool 2>/dev/null || true
    pipx install --force "$tool" || echo "[-] Failed: $tool"
done

# dnsrecon requires Python >=3.12 (its pyproject.toml rejects 3.10)
echo "[+] pipx install dnsrecon (Python 3.12)"
pipx install --force --python "$HOME/.pyenv/versions/3.12.9/bin/python3" dnsrecon || echo "[-] Failed: dnsrecon"

echo ""
echo "[*] Installing pipx tools from GitHub..."
pipx install git+https://github.com/Bashfuscator/Bashfuscator.git      || echo "[-] Failed: bashfuscator"
pipx install git+https://github.com/xmendez/wfuzz.git                 || echo "[-] Failed: wfuzz"
pipx install git+https://github.com/Pennyw0rth/NetExec.git             || echo "[-] Failed: NetExec"
pipx install git+https://github.com/cddmp/enum4linux-ng.git            || echo "[-] Failed: enum4linux-ng"
rm -f ~/bin/crowbar ~/bin/Sublist3r ~/bin/sublist3r 2>/dev/null || true
pipx install --force git+https://github.com/galkan/crowbar.git         || echo "[-] Failed: crowbar"
pipx install --force git+https://github.com/aboul3la/Sublist3r.git     || echo "[-] Failed: Sublist3r"

echo "[+] Installing NoSQLMap..."
mkdir -p ~/.local/src && cd ~/.local/src
[ ! -d "NoSQLMap" ] && git clone https://github.com/codingo/NoSQLMap.git
cd NoSQLMap
sed -i '' 's/pymongo==2.7.2/pymongo/g' setup.py 2>/dev/null || true
sed -i '' 's/CouchDB==1.0/CouchDB/g' setup.py 2>/dev/null || true
pipx install . || echo "[-] Failed: NoSQLMap"
cd - > /dev/null

# ============================================================
#  SECTION 8 — RUBY GEMS
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [8] RUBY GEMS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

sudo gem install evil-winrm cewl wpscan || gem install --user-install evil-winrm cewl wpscan || echo "[-] Failed: Ruby gems"

# ============================================================
#  SECTION 9 — GO TOOLS (go install)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [9] GO TOOLS (go install — always latest)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

export PATH="$HOME/go/bin:$PATH"

go install github.com/michenriksen/aquatone@latest                                       || echo "[-] Failed: aquatone"
go install github.com/tomnomnom/assetfinder@latest                                       || echo "[-] Failed: assetfinder"
go install github.com/ffuf/ffuf/v2@latest                                                || echo "[-] Failed: ffuf"
go install github.com/OJ/gobuster/v3@latest                                              || echo "[-] Failed: gobuster"
go install github.com/ropnop/kerbrute@latest                                             || echo "[-] Failed: kerbrute"
go install github.com/d3mondev/puredns/v2@latest                                         || echo "[-] Failed: puredns"
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest                 || echo "[-] Failed: subfinder"

# ============================================================
#  SECTION 10 — GUI APPS (Casks)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [10] GUI APPLICATIONS (Homebrew Casks)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

export HOMEBREW_NO_AUTO_UPDATE=1

CASKS=(
    burp-suite owasp-zap wireshark docker firefox opera antigravity-cli
    xquartz bloodhound metasploit
    nessus macfuse veracrypt chromium temurin@17 android-platform-tools dotnet-sdk
    sage vlc rar claude-code copilot-cli
    stats xbar tailscale-app
)

for cask in "${CASKS[@]}"; do
    brew install --cask "$cask" || echo "[-] Failed: $cask"
done

unset HOMEBREW_NO_AUTO_UPDATE

# ============================================================
#  SECTION 11 — ZSH: Oh My Zsh, Ubunly Theme & Plugins
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [11] ZSH — Oh My Zsh, Theme & Plugins"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[+] Oh My Zsh already installed."
fi

# Ubunly Theme
mkdir -p "$HOME/.oh-my-zsh/custom/themes"
if [ -f "$SCRIPT_DIR/ui_configs/ubunly.zsh-theme" ]; then
    cp "$SCRIPT_DIR/ui_configs/ubunly.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/ubunly.zsh-theme"
    echo "[+] Ubunly theme installed."
fi

# Custom Plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

PLUGINS=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
    "fast-syntax-highlighting:https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
)

for item in "${PLUGINS[@]}"; do
    pname="${item%%:*}"
    purl="${item#*:}"
    if [ ! -d "$ZSH_CUSTOM/plugins/$pname" ]; then
        echo "[+] Cloning plugin: $pname..."
        git clone --depth 1 "$purl" "$ZSH_CUSTOM/plugins/$pname"
    else
        echo "[+] Plugin $pname already installed."
    fi
done

# .zshrc template
if [ -f "$SCRIPT_DIR/zshrc_template" ]; then
    [ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.backup_setup
    cp "$SCRIPT_DIR/zshrc_template" ~/.zshrc
    echo "[+] .zshrc installed (backup: ~/.zshrc.backup_setup)."
fi

# ============================================================
#  SECTION 12 — NANO CONFIG & MIPS SYNTAX
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [12] NANO CONFIG & MIPS SYNTAX HIGHLIGHTING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

NANO_BIN="${BREW_PREFIX}/bin/nano"
if [ -x "$NANO_BIN" ]; then
    echo "[+] Brew nano found. Installing ~/.nanorc..."

    cat > "$HOME/.nanorc" << NANORC
# --- VISUALS ---
set linenumbers
set indicator
set minibar

# --- MOUSE & MOVEMENT ---
set mouse
set smarthome
set positionlog

# --- CODING ---
set tabsize 4
set tabstospaces
set autoindent

# --- SYNTAX HIGHLIGHTING ---
include "${BREW_PREFIX}/share/nano/*.nanorc"
include "~/.nano/mips.nanorc"
NANORC

    mkdir -p "$HOME/.nano"
    cat > "$HOME/.nano/mips.nanorc" << 'MIPSRC'
syntax "mips" "\.(s|S)$"

# MIPS Instructions (Green)
icolor green "\<(add|addi|addu|sub|subu|and|or|xor|nor|sll|srl|sra|lw|sw|lb|sb|beq|bne|j|jal|jr|li|la|move|syscall|mfhi|mflo|mult|div)\>"

# MIPS Registers (Red)
icolor brightred "\$(zero|at|v[0-1]|a[0-3]|t[0-9]|s[0-7]|k[0-1]|gp|sp|fp|ra|[0-9]+)"

# Labels (Cyan)
icolor cyan "^[[:space:]]*[A-Za-z0-9_]+:"

# Strings (Yellow)
icolor yellow "\".*\""

# Comments (Blue)
icolor brightblue "#.*"
MIPSRC

    echo "[+] ~/.nanorc and ~/.nano/mips.nanorc installed."
else
    echo "[-] Brew nano not found at $NANO_BIN — skipping nanorc. (Install with: brew install nano)"
fi

# ============================================================
#  SECTION 13 — UI TWEAKS (xbar & Stats)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [13] MENU BAR UI (Stats & xbar)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "$SCRIPT_DIR/ui_configs" ]; then
    XBAR_PLUGINS="$HOME/Library/Application Support/xbar/plugins"
    mkdir -p "$XBAR_PLUGINS"

    if [ -f "$SCRIPT_DIR/ui_configs/vpn_ip.10s.sh" ]; then
        cp "$SCRIPT_DIR/ui_configs/vpn_ip.10s.sh" "$XBAR_PLUGINS/"
        chmod +x "$XBAR_PLUGINS/vpn_ip.10s.sh"
        echo "[+] xbar VPN monitor plugin installed."
        xattr -r -d com.apple.quarantine /Applications/xbar.app 2>/dev/null || true
        open -a xbar 2>/dev/null || true
    fi

    if [ -f "$SCRIPT_DIR/ui_configs/eu.exelban.Stats.plist" ]; then
        killall Stats 2>/dev/null || true
        defaults import eu.exelban.Stats "$SCRIPT_DIR/ui_configs/eu.exelban.Stats.plist" 2>/dev/null || true
        echo "[+] Stats configuration imported."
        xattr -r -d com.apple.quarantine /Applications/Stats.app 2>/dev/null || true
        open -a Stats 2>/dev/null || true
    fi
fi

# ============================================================
#  SECTION 14 — CUSTOM SCRIPTS (whatport, etc.)
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [14] CUSTOM SCRIPTS (whatport)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "$SCRIPT_DIR/custom_scripts" ]; then
    echo "Installing custom toolkit scripts..."
    mkdir -p "$HOME/bin"
    for script in "$SCRIPT_DIR/custom_scripts"/*; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            script_name=$(basename "$script")
            ln -sf "$script" "$HOME/bin/$script_name"
            echo "  [+] Linked $script_name to ~/bin/"
        fi
    done
else
    echo "[-] custom_scripts directory not found. Skipping."
fi

# ============================================================
#  SECTION 15 — GITHUB TOOLS & WORDLISTS
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  [15] GITHUB TOOLS & WORDLISTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "$SCRIPT_DIR/install_github_tools.sh" ]; then
    chmod +x "$SCRIPT_DIR/install_github_tools.sh"
    "$SCRIPT_DIR/install_github_tools.sh" "$SELECTED_TOOLS_DIR"
else
    echo "[-] install_github_tools.sh not found. Skipping."
fi

# ============================================================
#  DONE BANNER
# ============================================================
echo ""
cat << 'DONE'
  ██████╗  ██████╗ ███╗   ██╗███████╗██╗
  ██╔══██╗██╔═══██╗████╗  ██║██╔════╝██║
  ██║  ██║██║   ██║██╔██╗ ██║█████╗  ██║
  ██║  ██║██║   ██║██║╚██╗██║██╔══╝  ╚═╝
  ██████╔╝╚██████╔╝██║ ╚████║███████╗██╗
  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝
DONE

echo ""
echo "============================================================"
echo "  HackBook Setup Complete!"
echo "============================================================"
echo ""
echo "  Tools installed to: $SELECTED_TOOLS_DIR"
echo ""
echo "  NEXT STEPS:"
echo "  1. Restart terminal or: source ~/.zshrc"
echo "  2. Open Docker.app to start the Docker Engine"
echo "  3. Run your labs: kali-linux-lab / parrot-os-lab"
echo ""
echo "  [!] IMPORTANT FOR PIPX TOOLS (Impacket, droopescan, etc.):"
echo "      It is HIGHLY RECOMMENDED to use the provided zshrc_template!"
echo "      If you choose to keep your own, you MUST manually add the"
echo "      PIPX_HOME and PIPX_DEFAULT_PYTHON variables to your ~/.zshrc,"
echo "      otherwise these tools will crash or fail to run."
echo ""
echo "  +-----------------------------------------------------+"
echo "  |  TERMINAL THEME — MANUAL STEP REQUIRED             |"
echo "  |                                                     |"
echo "  |  To install your Kali Linux Terminal theme:         |"
echo "  |  1. Open Terminal -> Settings -> Profiles           |"
echo "  |  2. Click gear icon (bottom-left)                   |"
echo "  |  3. Choose 'Import...'                              |"
echo "  |  4. Select file:                                    |"
echo "  |     mac mitigation/custom terminal profile/         |"
echo "  |     Custom_KaliLinux_Style.terminal                 |"
echo "  |  5. Right-click the new profile -> 'Default'        |"
echo "  +-----------------------------------------------------+"
echo ""
echo "  Docker pre-download (optional):"
echo "    docker pull 0x3xplt1/kali-linux-lab:latest"
echo "    docker pull 0x3xplt1/parrot-os-lab:latest"
echo "============================================================"

