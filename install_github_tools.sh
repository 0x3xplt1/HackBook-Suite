#!/bin/bash

# HackBook Suite — GitHub Tools Installer
# This script downloads and structures all manual GitHub tools needed for the toolkit.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Accept explicit path argument or default to ~/Tools
if [ -n "$1" ] && [ "$1" != "--icloud" ] && [ "$1" != "--sync" ]; then
    INSTALL_DIR="$1"
    echo "Installing GitHub tools to: $INSTALL_DIR"
elif [[ "$1" == "--icloud" || "$1" == "--sync" ]]; then
    INSTALL_DIR="$HOME/Documents/Tools"
    echo "iCloud Sync Mode Enabled: Installing to $INSTALL_DIR"
elif [ -d "$HOME/Documents/Tools" ]; then
    INSTALL_DIR="$HOME/Documents/Tools"
    echo "Existing Tools folder found in Documents: Installing to $INSTALL_DIR"
else
    INSTALL_DIR="$HOME/Tools"
    echo "Standard Mode: Installing to $INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

echo -e "\n[*] Fetching offline CyberChef..."
if ls "$INSTALL_DIR/CyberChef/CyberChef_v"*.html 1> /dev/null 2>&1; then
    echo "[~] CyberChef is already downloaded, skipping."
else
    LATEST_CC_URL=$(curl -s https://api.github.com/repos/gchq/CyberChef/releases/latest | grep "browser_download_url.*\.zip" | awk -F"\"" '{print $4}')
    if [ -n "$LATEST_CC_URL" ]; then
        mkdir -p "$INSTALL_DIR/CyberChef"
        curl -sL "$LATEST_CC_URL" -o /tmp/CyberChef.zip
        unzip -o -q /tmp/CyberChef.zip -d "$INSTALL_DIR/CyberChef/"
        rm /tmp/CyberChef.zip
        echo "[+] CyberChef downloaded successfully."
    else
        echo "[-] Failed to find CyberChef release URL."
    fi
fi
echo "========================================"

# Tool List
declare -A REPOS=(
    ["DPAT"]="https://github.com/clr2of8/DPAT.git"
    ["XSStrike"]="https://github.com/s0md3v/XSStrike.git"
    ["dnsenum"]="https://github.com/fwaeytens/dnsenum.git"
    ["subbrute"]="https://github.com/TheRook/subbrute.git"
    ["odat"]="https://github.com/quentinhardy/odat.git"
    ["LFISuite"]="https://github.com/D35m0nd142/LFISuite.git"
    ["LFiFreak"]="https://github.com/OsandaMalith/LFiFreak.git"
    ["FinalRecon"]="https://github.com/thewhiteh4t/FinalRecon.git"
    ["ReconSpider"]="https://github.com/bhavsec/reconspider.git"
    ["bashfuscator"]="https://github.com/Bashfuscator/Bashfuscator.git"
    ["EyeWitness"]="https://github.com/RedSiege/EyeWitness.git"
    ["SSTImap"]="https://github.com/vladko312/SSTImap.git"
    ["tplmap"]="https://github.com/epinna/tplmap.git"
    ["graphql-cop"]="https://github.com/doyensec/graphql-cop.git"
    ["joomscan"]="https://github.com/OWASP/joomscan.git"
    ["joomla-bruteforce"]="https://github.com/X-Vector/joomla-brute.git"
    ["social-engineer-toolkit"]="https://github.com/trustedsec/social-engineer-toolkit.git"
    ["o365spray"]="https://github.com/0xZDH/o365spray.git"
    ["BruteXSS"]="https://github.com/rajeshmajumdar/BruteXSS.git"
    ["graphw00f"]="https://github.com/dolevf/graphw00f.git"
    ["smtp-user-enum"]="https://github.com/pentestmonkey/smtp-user-enum.git"
    ["EmailHarvester"]="https://github.com/maldevel/EmailHarvester.git"
    ["recon-ng"]="https://github.com/lanmaster53/recon-ng.git"
    ["username-anarchy"]="https://github.com/urbanadventurer/username-anarchy.git"
    ["PCredz"]="https://github.com/lgandx/PCredz.git"
    ["reverse-shell-generator"]="https://github.com/0dayCTF/reverse-shell-generator.git"
    ["KeyTabExtract"]="https://github.com/sosdave/KeyTabExtract.git"
    ["PKINITtools"]="https://github.com/dirkjanm/PKINITtools.git"
    ["krbrelayx"]="https://github.com/dirkjanm/krbrelayx.git"
    ["mimipenguin"]="https://github.com/huntergregal/mimipenguin.git"
)

for folder in "${!REPOS[@]}"; do
    if [ ! -d "$folder" ]; then
        echo "Cloning $folder..."
        git clone "${REPOS[$folder]}" "$folder"
    else
        echo "[~] $folder already exists, skipping."
    fi
done

# ========================================
# Post-Clone Automated Patches
# ========================================
if [ -f "$INSTALL_DIR/BruteXSS/brutexss.py" ]; then
    if ! grep -q "_create_unverified_https_context" "$INSTALL_DIR/BruteXSS/brutexss.py"; then
        echo "Applying automated SSL patch to BruteXSS..."
        sed -i '' -e '11i\
import ssl\
try:\
    _create_unverified_https_context = ssl._create_unverified_context\
except AttributeError:\
    pass\
else:\
    ssl._create_default_https_context = _create_unverified_https_context\
' "$INSTALL_DIR/BruteXSS/brutexss.py"
    fi
fi

if [ -f "$INSTALL_DIR/smtp-user-enum/smtp-user-enum.pl" ]; then
    echo "Configuring smtp-user-enum symlink in ~/bin..."
    chmod +x "$INSTALL_DIR/smtp-user-enum/smtp-user-enum.pl"
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/smtp-user-enum/smtp-user-enum.pl" "$HOME/bin/smtp-user-enum"
fi

if [ -f "$INSTALL_DIR/EmailHarvester/EmailHarvester.py" ]; then
    echo "Configuring EmailHarvester..."
    cd "$INSTALL_DIR/EmailHarvester"
    python3 -m pip install -r requirements.txt 2>/dev/null || true
    chmod +x EmailHarvester.py
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/EmailHarvester/EmailHarvester.py" "$HOME/bin/emailharvester"
    cd - > /dev/null
fi

if [ -f "$INSTALL_DIR/recon-ng/recon-ng" ]; then
    echo "Configuring recon-ng..."
    cd "$INSTALL_DIR/recon-ng"
    python3 -m pip install -r REQUIREMENTS 2>/dev/null || true
    chmod +x recon-ng recon-cli recon-web
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/recon-ng/recon-ng" "$HOME/bin/recon-ng"
    ln -sf "$INSTALL_DIR/recon-ng/recon-cli" "$HOME/bin/recon-cli"
    ln -sf "$INSTALL_DIR/recon-ng/recon-web" "$HOME/bin/recon-web"
    cd - > /dev/null
fi

if [ -f "$INSTALL_DIR/username-anarchy/username-anarchy" ]; then
    echo "Configuring username-anarchy symlink in ~/bin..."
    chmod +x "$INSTALL_DIR/username-anarchy/username-anarchy"
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/username-anarchy/username-anarchy" "$HOME/bin/username-anarchy"
fi

if [ -f "$INSTALL_DIR/PCredz/Pcredz" ]; then
    echo "Configuring PCredz..."
    python3 -m pip install pcapy-ng 2>/dev/null || true
    chmod +x "$INSTALL_DIR/PCredz/Pcredz"
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/PCredz/Pcredz" "$HOME/bin/Pcredz"
fi

if [ -f "$INSTALL_DIR/KeyTabExtract/keytabextract.py" ]; then
    echo "Configuring KeyTabExtract symlinks in ~/bin..."
    chmod +x "$INSTALL_DIR/KeyTabExtract/keytabextract.py"
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/KeyTabExtract/keytabextract.py" "$HOME/bin/keytabextract"
    ln -sf "$INSTALL_DIR/KeyTabExtract/keytabextract.py" "$HOME/bin/keytabextract.py"
    ln -sf "$INSTALL_DIR/KeyTabExtract/keytabextract.py" "$HOME/bin/keytab2john"
    ln -sf "$INSTALL_DIR/KeyTabExtract/keytabextract.py" "$HOME/bin/keytab2john.py"
fi

if [ -d "$INSTALL_DIR/PKINITtools" ]; then
    echo "Configuring PKINITtools..."
    python3 -m pip install minikerberos 2>/dev/null || true
    chmod +x "$INSTALL_DIR/PKINITtools/gettgtpkinit.py" "$INSTALL_DIR/PKINITtools/getnthash.py" 2>/dev/null || true
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/PKINITtools/gettgtpkinit.py" "$HOME/bin/gettgtpkinit.py"
    ln -sf "$INSTALL_DIR/PKINITtools/gettgtpkinit.py" "$HOME/bin/gettgtpkinit"
    ln -sf "$INSTALL_DIR/PKINITtools/getnthash.py" "$HOME/bin/getnthash.py"
    ln -sf "$INSTALL_DIR/PKINITtools/getnthash.py" "$HOME/bin/getnthash"
fi

if [ -d "$INSTALL_DIR/krbrelayx" ]; then
    echo "Configuring krbrelayx..."
    chmod +x "$INSTALL_DIR/krbrelayx/"*.py 2>/dev/null || true
    mkdir -p "$HOME/bin"
    for tool in printerbug krbrelayx addspn dnstool; do
        if [ -f "$INSTALL_DIR/krbrelayx/${tool}.py" ]; then
            ln -sf "$INSTALL_DIR/krbrelayx/${tool}.py" "$HOME/bin/${tool}.py"
            ln -sf "$INSTALL_DIR/krbrelayx/${tool}.py" "$HOME/bin/${tool}"
        fi
    done
fi

if [ -d "$INSTALL_DIR/mimipenguin" ]; then
    echo "Configuring mimipenguin..."
    chmod +x "$INSTALL_DIR/mimipenguin/mimipenguin.sh" "$INSTALL_DIR/mimipenguin/mimipenguin.py" 2>/dev/null || true
    mkdir -p "$HOME/bin"
    ln -sf "$INSTALL_DIR/mimipenguin/mimipenguin.sh" "$HOME/bin/mimipenguin.sh"
    ln -sf "$INSTALL_DIR/mimipenguin/mimipenguin.sh" "$HOME/bin/mimipenguin"
    ln -sf "$INSTALL_DIR/mimipenguin/mimipenguin.py" "$HOME/bin/mimipenguin.py"
fi

if [ -d "$INSTALL_DIR/reverse-shell-generator" ]; then
    echo "[*] Building local-revshells Docker image (this may take a moment)..."
    docker build -t local-revshells "$INSTALL_DIR/reverse-shell-generator" && \
        echo "[+] local-revshells image built successfully." || \
        echo "[-] Docker build failed. Make sure Docker Desktop is running."
fi

# ========================================
# John the Ripper (openwall bleeding-jumbo)
# Handles both fresh install and updates.
# ========================================
echo ""
echo "[*] Setting up John the Ripper (bleeding-jumbo)..."

JOHN_DIR="$INSTALL_DIR/john"
JOHN_BRANCH="bleeding-jumbo"

_setup_john_symlinks() {
    local dir="$1"
    echo "[*] Ensuring extensionless symlinks and john launcher in $dir/run..."
    mkdir -p "$HOME/bin"

    # 1. Launcher in ~/bin to invoke john with full path (resolves john.conf)
    cat << 'EOF' > "$HOME/bin/john"
#!/bin/bash
TOOLS="${TOOLS_DIR:-$HOME/Documents/Tools}"
if [ ! -d "$TOOLS/john/run" ] && [ -d "$HOME/Tools/john/run" ]; then
    TOOLS="$HOME/Tools"
fi
exec "$TOOLS/john/run/john" "$@"
EOF
    chmod +x "$HOME/bin/john"

    # 2. Extensionless symlinks for *2john.py and *2john.pl (ssh2john, pdf2john, etc.)
    for script in "$dir/run/"*2john.py "$dir/run/"*2john.pl; do
        [ -f "$script" ] || continue
        local base_name
        base_name=$(basename "$script")
        local name_without_ext="${base_name%.*}"
        if [ ! -e "$dir/run/$name_without_ext" ]; then
            ln -sf "$base_name" "$dir/run/$name_without_ext"
        fi
    done
}

_build_john() {
    local dir="$1"
    echo "[*] Building john from source (this may take a few minutes)..."

    # Auto-detect latest Homebrew gcc (e.g. gcc-16, gcc-15, ...)
    local GCC_BIN
    GCC_BIN=$(ls /opt/homebrew/bin/gcc-[0-9]* 2>/dev/null \
        | grep -v "ar\|nm\|ranlib" | sort -V | tail -1)

    if [ -z "$GCC_BIN" ]; then
        echo "[-] No Homebrew gcc found. Install with: brew install gcc"
        echo "    Falling back to system cc (performance will be suboptimal)."
        GCC_BIN="cc"
    else
        echo "[~] Using compiler: $GCC_BIN"
    fi

    local CPU_COUNT
    CPU_COUNT=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

    cd "$dir/src" || return 1

    ./configure \
        CC="$GCC_BIN" \
        LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/libpcap/lib" \
        CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/libpcap/include" \
        AR="/usr/bin/ar" \
        RANLIB="/usr/bin/ranlib" 2>&1 | tail -3

    make -s clean && make -sj"$CPU_COUNT" && \
        echo "[+] John built successfully → $dir/run/john" || \
        echo "[-] Build failed. Check output above."

    cd - > /dev/null
    _setup_john_symlinks "$dir"
}

if [ ! -d "$JOHN_DIR" ]; then
    echo "[*] Cloning openwall/john (bleeding-jumbo)..."
    git clone --branch "$JOHN_BRANCH" https://github.com/openwall/john.git "$JOHN_DIR"
    brew install libpcap 2>/dev/null | grep -v "already installed" || true
    _build_john "$JOHN_DIR"
elif [ -d "$JOHN_DIR/.git" ]; then
    echo "[~] john already cloned — checking for updates..."
    PULL_OUT=$(git -C "$JOHN_DIR" pull 2>&1)
    echo "$PULL_OUT"
    if echo "$PULL_OUT" | grep -q "Already up to date"; then
        echo "[~] No changes — ensuring symlinks are up to date."
        _setup_john_symlinks "$JOHN_DIR"
    else
        echo "[*] Changes detected — rebuilding john..."
        _build_john "$JOHN_DIR"
    fi
else
    echo "[~] $JOHN_DIR exists but is not a git repo — skipping."
fi


echo "========================================"
echo "Done! All tools cloned to $INSTALL_DIR"
echo "[!] Note: You may need to run 'pip install -r requirements.txt' individually inside specific tool directories."

# Automatically run the wordlist symlinker now that all tools are downloaded
echo ""
echo "Initializing portable wordlists..."
if [ -f "$SCRIPT_DIR/setup_wordlists.sh" ]; then
    chmod +x "$SCRIPT_DIR/setup_wordlists.sh"
    "$SCRIPT_DIR/setup_wordlists.sh" "$INSTALL_DIR"
else
    echo "[-] setup_wordlists.sh not found at $SCRIPT_DIR/setup_wordlists.sh. Skipping."
fi
