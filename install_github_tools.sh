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
