#!/bin/bash

# HackBook Suite — Wordlist Symlinker
# This script creates relative symlinks for wordlists so they are completely portable 
# across any Mac, regardless of the username.

# Determine the correct Tools directory
if [ -n "$1" ] && [ -d "$1" ]; then
    TOOLS_DIR="$1"
elif [ -d "$HOME/Documents/Tools" ]; then
    TOOLS_DIR="$HOME/Documents/Tools"
else
    TOOLS_DIR="$HOME/Tools"
fi

WORDLISTS_DIR="$TOOLS_DIR/wordlists"

echo "[*] Setting up portable Wordlists in: $WORDLISTS_DIR"
mkdir -p "$WORDLISTS_DIR"
cd "$WORDLISTS_DIR" || exit

echo "[+] Creating relative symlinks..."

# 1. SecLists (The Master List)
if [ -d "../SecLists" ]; then
    ln -sfn ../SecLists seclists
    
    # Auto-extract rockyou.txt if it's compressed and hasn't been extracted yet
    if [ ! -f "../SecLists/Passwords/Leaked-Databases/rockyou.txt" ] && [ -f "../SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz" ]; then
        echo "  [*] Extracting rockyou.txt (this may take a moment)..."
        tar -xzf ../SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C ../SecLists/Passwords/Leaked-Databases/
    fi

    ln -sfn ../SecLists/Passwords/Leaked-Databases/rockyou.txt rockyou.txt
    echo "  -> Linked SecLists & rockyou.txt"
fi

# 2. PayloadsAllTheThings
if [ -d "../PayloadsAllTheThings" ]; then
    ln -sfn ../PayloadsAllTheThings payloads
    echo "  -> Linked PayloadsAllTheThings"
fi

# 3. Dirb
if [ -d "../dirb/wordlists" ]; then
    ln -sfn ../dirb/wordlists dirb
    echo "  -> Linked dirb"
fi

# 4. Wfuzz
if [ -d "../wfuzz/wordlist" ]; then
    ln -sfn ../wfuzz/wordlist wfuzz
    echo "  -> Linked wfuzz"
fi

# 5. Fasttrack (SET)
if [ -d "../social-engineer-toolkit/src/fasttrack" ]; then
    ln -sfn ../social-engineer-toolkit/src/fasttrack/wordlist.txt fasttrack.txt
    echo "  -> Linked fasttrack.txt"
fi

# ==========================================
# SYSTEM / HOMEBREW SPECIFIC LINKS
# These must be absolute paths because they live outside the Tools folder
# ==========================================
echo "[+] Creating system tool symlinks (Homebrew/Metasploit)..."

# NMAP Wordlists
if command -v brew >/dev/null 2>&1; then
    NMAP_PATH="$(brew --prefix nmap)/share/nmap/nselib/data/passwords.lst"
    if [ -f "$NMAP_PATH" ]; then
        ln -sfn "$NMAP_PATH" nmap.lst
        echo "  -> Linked nmap.lst"
    fi
    
    # John the Ripper Wordlist
    JOHN_PATH="$(brew --prefix john-jumbo)/share/john/password.lst"
    if [ -f "$JOHN_PATH" ]; then
        ln -sfn "$JOHN_PATH" john.lst
        echo "  -> Linked john.lst"
    fi
fi

if [ -d "/opt/metasploit-framework/embedded/framework/data/wordlists" ]; then
    ln -sfn /opt/metasploit-framework/embedded/framework/data/wordlists metasploit
    echo "  -> Linked metasploit"
fi

# ==========================================
# RAW GITHUB DOWNLOADS (For tools installed via Pipx or missing in Brew)
# ==========================================
echo "[+] Fetching missing standalone wordlists directly from GitHub..."

# SQLMap Wordlist (Since we use Pipx instead of a full Git clone)
if [ ! -f "sqlmap.txt" ]; then
    curl -s -L "https://raw.githubusercontent.com/sqlmapproject/sqlmap/master/data/txt/wordlist.txt" -o sqlmap.txt
    echo "  -> Downloaded sqlmap.txt"
fi

# DNSMap Wordlist (Modern Homebrew versions of dnsmap omit the wordlist)
if [ ! -f "dnsmap.txt" ]; then
    curl -s -L "https://raw.githubusercontent.com/resurrecting-open-source-projects/dnsmap/master/wordlist_TLAs.txt" -o dnsmap.txt
    echo "  -> Downloaded dnsmap.txt"
fi

echo "========================================"
echo "[+] Success! Your wordlists folder is now fully portable."
echo "========================================"
