# HackBook Suite

Turn your Mac into a proper pentesting machine. This toolkit sets up the tools, aliases, Docker labs, and terminal config you need to work through HackTheBox, TryHackMe, and real engagements without constantly fighting macOS quirks.

Works on both Intel and Apple Silicon.

## Install

```bash
git clone https://github.com/0x3xplt1/HackBook-Suite.git
cd HackBook-Suite
chmod +x HackBook_setup.sh
./HackBook_setup.sh
```

> **Note:** macOS may ask for Terminal permissions (App Management, System Events) to configure `xbar` and `Stats`. Click Allow when prompted.

### What gets installed

- Homebrew + GNU core utilities (replaces BSD tools with Linux equivalents)
- Python version management via `pyenv` (3.10, 3.12, 3.13, 3.14)
- Security tools via `pipx`: `impacket`, `pypykatz`, `oletools`, `h8mail`, `uploadserver`, `xortool`, `hashid`, `name-that-hash`, `firefox-decrypt`, `wpscan`, and more
- Go tools: `ffuf`, `gobuster`, `chisel`, `kerbrute`, `subfinder`, `aquatone`, etc.
- `nano` with syntax highlighting (includes MIPS Assembly)
- Mars4_5 MIPS simulator
- ZSH with `ubunly` theme + autosuggestions + fast-syntax-highlighting
- `xbar` and `Stats` for menu-bar monitoring
- `~/DockerLabs` folder structure for Docker file sharing

---

## Standalone Tools (Non-Homebrew)

These tools aren't in Homebrew or need special setup to work correctly on macOS.

### smtp-user-enum

The original Perl script from pentestmonkey. Flags like `-M`, `-U`, `-t` work exactly as written in HTB writeups.

```bash
cd ~/Documents/Tools
git clone https://github.com/pentestmonkey/smtp-user-enum.git pentestmonkey-smtp-user-enum
ln -sf ~/Documents/Tools/pentestmonkey-smtp-user-enum/smtp-user-enum.pl ~/bin/smtp-user-enum
```

```bash
smtp-user-enum -M VRFY -U users.txt -t <target_ip>
```

---

### whatport

A small script that gives you hacking context for a port number, not just the service name. Run it right after an Nmap scan to know what to try next.

It checks ~45 common CTF/HTB ports first (SMB, WinRM, MSSQL, etc.) and falls back to the Nmap services database for anything obscure.

```bash
whatport 445
whatport 31337
```

---

### urlencode & urldecode

Custom ZSH functions built in Python to safely encode and decode XSS payloads directly from the terminal. Unlike basic web encoders, these use strict encoding (`safe=''`) to ensure that all characters, including forward slashes (`/`), are converted properly to bypass WAFs.

```bash
$ urlencode '<script>alert(document.domain)</script>'
%3Cscript%3Ealert%28document.domain%29%3C%2Fscript%3E

$ urldecode '%3Cscript%3Ealert%28document.domain%29%3C%2Fscript%3E'
<script>alert(document.domain)</script>
```

---

### emailharvester

The dedicated package for finding domain emails in search engines. Handled automatically by the GitHub tools script (cloned, requirements installed, and symlinked).

```bash
emailharvester -d example.com -e google
```

---

### recon-ng

The famous OSINT web reconnaissance framework. The automated GitHub installer clones it, installs its Python dependencies, and maps the binaries to your path.

```bash
recon-ng
```

**Quick Start Guide:**
Modern `recon-ng` ships empty by default. You must install modules from the marketplace:
1. `workspaces create <target>` — Create a new project workspace.
2. `marketplace search` — List all available modules.
3. `marketplace install hackertarget` — Install a specific module (no API key needed).
4. `modules load hackertarget` — Load the module for use.
5. `options set SOURCE example.com` — Define your target domain.
6. `run` — Execute the scan.
7. `show hosts` — View the gathered results.

---

### xorsearch

Didier Stevens' XOR/ROT string scanner — standard tool for malware analysis. Searches inside binary files for encoded strings like URLs, IPs, or shellcode. Not on Homebrew, so build it from source (takes about 5 seconds):

```bash
mkdir -p ~/Documents/Tools/XORSearch && cd ~/Documents/Tools/XORSearch
curl -O https://didierstevens.com/files/software/XORSearch_V1_11_3.zip
unzip -q XORSearch_V1_11_3.zip
gcc XORSearch.c -o xorsearch
rm XORSearch_V1_11_3.zip
```

```bash
xorsearch malware.exe http
```

---

### username-anarchy

The classic Ruby tool for generating permutations of usernames from names (First Last -> flast, first.last, etc.) for brute-force and password spraying attacks. Handled automatically by the GitHub tools installer and symlinked to your path.

```bash
username-anarchy -i names.txt
username-anarchy "John Doe"
```

---

### PCredz

Extracts credentials (NTLM, Kerberos, HTTP Basic, LDAP, SNMP, etc.) from pcap files or live network traffic. Handled automatically by the GitHub tools installer and symlinked to your path as `Pcredz`.

```bash
Pcredz -f capture.pcap
Pcredz -d /path/to/pcaps/
```

---

### John the Ripper (Bleeding-Jumbo)

Built directly from upstream `openwall/john` (`bleeding-jumbo`) with full Apple Silicon ARM ASIMD and OpenMP multicore acceleration. 

All 115+ conversion scripts and formats are mapped to your `$PATH` both with and without extensions so any writeup or command works seamlessly:

```bash
# Core cracker
john --wordlist=$WORDLISTS/rockyou.txt hash.txt

# Format converters (work identically with or without .py / .pl extension)
ssh2john id_rsa > hash.txt
ssh2john.py id_rsa > hash.txt

pdf2john sample.pdf > hash.txt
pdf2john.pl sample.pdf > hash.txt

zip2john archive.zip > hash.txt
rar2john archive.rar > hash.txt
```

---

### KeyTabExtract (Kerberos Keytabs)

Extracts service and NTLM credentials from Kerberos `.keytab` files. Symlinked to your path as `keytabextract`, `keytabextract.py`, and aliased to `keytab2john` for workflow compatibility:

```bash
keytabextract /etc/krb5.keytab
keytab2john /etc/krb5.keytab
```

---

## macOS Command Parity & GNU Utilities

macOS is BSD-based, so several standard Linux tools are either missing or behave differently. The toolkit installs the GNU versions via Homebrew and maps them so copy-pasted Linux commands just work:

| Command | What it does |
|---------|-------------|
| `sed` | Aliased to `gsed`. Fixes `-i` in-place editing errors on macOS |
| `strings` | Aliased to `gstrings` (binutils). Reads ELF binaries correctly |
| `nc` | Wrapped with `rlwrap`. Adds arrow keys and history to reverse shells |
| `ftp` / `telnet` | Restored via `inetutils` (Apple removed them in High Sierra) |
| `mysql` | Aliased to `mariadb` (see below) |
| `updatedb` | Aliased to `sudo /usr/libexec/locate.updatedb`. Builds/refreshes the `locate` index |

### mysql → mariadb

Modern Oracle MySQL (v8.4+) dropped `mysql_native_password` and `--ssl=0`. A lot of older HTB targets rely on both. To maintain compatibility, this toolkit routes `mysql` through MariaDB:

```bash
alias mysql="mariadb"
```

Copy-paste `mysql` commands from writeups and they work.

---

### windows-resources (Windows Attack Resources)

Provides an organized directory structure in `$TOOLS_DIR/windows-resources`. Contains authentic Windows binaries, frameworks, and privilege escalation tools (`LaZagne`, `winPEAS`, `mimikatz`, `PowerSploit`, `nishang`, `powercat`, `chisel`, `SharpHound`, `RunasCs`, `PrintSpoofer`, `GodPotato`, `Seatbelt`, `SharpDPAPI`, etc.).

**How to use:**
Simply copy the required binary directly into your engagement or lab folder:
```bash
cp "$TOOLS_DIR/windows-resources/binaries/winPEASx64.exe" .
python3 -m http.server 80
```

**Automated updates:**
* `sysupdate` — automatically updates all cloned windows-resources repositories (`powersploit`, `nishang`, `mimikatz`, `powercat`, etc.) as well as fetching the latest GitHub release binaries.
* `update-windows-binaries` — standalone script to refresh all precompiled Windows `.exe` tools on demand.

---

## Docker Labs 🐳

Pre-configured containers for Kali, Parrot OS, and REMnux. Each one gets `NET_ADMIN` capabilities, VPN tunnel access, VNC ports, and a shared folder mounted from your Mac.

```bash
kali-linux-lab       # Kali Linux
parrot-os-lab        # Parrot OS
remnux-lab           # REMnux (malware analysis)
manspider            # MANSPIDER (SMB share spidering and credential searching)
revshells            # Reverse Shell Generator — local web UI at http://127.0.0.1:8888
```

Containers are temporary by default — removed on exit. For `manspider`, loot and databases are automatically saved to `./manspider` in your current directory.

### Reverse Shell Generator

Browser-based reverse shell builder running locally. No internet needed after build. Configs are stored in browser localStorage.

```bash
# First-time setup (run once via install_github_tools.sh, or manually):
cd $TOOLS_DIR/reverse-shell-generator && docker build -t local-revshells .

# Start (opens browser automatically at http://127.0.0.1:8888)
revshells

# Stop + verify port 8888 is free
revshells-stop
```


### Persist changes

```bash
kali-linux-lab --persist
```

To save and push:
```bash
docker commit <container_id> 0x3xplt1/kali-linux-lab:latest
docker push 0x3xplt1/kali-linux-lab:latest
```

### Shared folder

`~/DockerLabs/docker-shared-data` on your Mac → `/root/shared/` inside the container.

---

## VPN Monitor

The `xbar` plugin (`ui_configs/vpn_ip.10s.sh`) reads your active OpenVPN interface and shows the label in the menu bar:

- HTB Academy / Starting Point
- TryHackMe
- OffSec (PG / OSCP)

Tailscale `100.x.x.x` addresses are ignored.

> If you're on a 14" MacBook with the notch: hide the Wi-Fi/Bluetooth/Battery icons in System Settings → Control Center to free up space. They stay accessible via Control Center.

---

## Gatekeeper & Quarantine

macOS tags downloaded files with `com.apple.quarantine`, which blocks security tools from running. The `--no-quarantine` Homebrew flag was removed, so you manage it manually.

### Remove quarantine from an app

```bash
unquarantine Chromium
unquarantine "Burp Suite Community Edition"
```

### Check a single app

```bash
xattr /Applications/<App>.app
```

- `com.apple.quarantine` — blocked by Gatekeeper
- `com.apple.provenance` — harmless tracking tag, not quarantined
- *(empty)* — clean

### Scan all apps

```bash
scan-quarantine
```

Apps that show up in the scan but open fine don't need to be touched — macOS sometimes leaves the attribute behind even after you approve an app.

---

## Customization

- **Wordlists:** Put them in `~/DockerLabs/docker-shared-data` → they show up at `/root/shared/` inside containers.
- **Metasploit modules:** Drop `.rb` files in `~/.msf4/modules/exploits/`.

---

## File Structure

```
macOS-Cybersecurity-Toolkit/
├── HackBook_setup.sh        # Main installer
├── install_github_tools.sh  # Clones manual tools to ~/Tools
├── setup_wordlists.sh       # Sets up wordlist structure
├── zshrc_template           # ZSH config with all aliases and functions
├── assets/                  # Binaries (Mars4_5.jar, etc.)
├── docker/                  # Dockerfiles
└── ui_configs/
    ├── vpn_ip.10s.sh        # xbar VPN monitor plugin
    ├── Stats.plist          # Stats app layout
    └── ubunly.zsh-theme     # Terminal theme
```

**Where config files go:**
- `vpn_ip.10s.sh` → `~/Library/Application Support/xbar/plugins/`
- `Stats.plist` → `~/Library/Preferences/eu.exelban.Stats.plist`
- `mips.nanorc` → `~/.nano/mips.nanorc`
- `zshrc_template` → `~/.zshrc` (original backed up to `~/.zshrc.backup_setup`)

## Privacy & Dark Web Tools
- **ProtonVPN:** A highly secure, strict no-logs VPN (installed via Cask).
- **Tor & Tor Browser:** Background tor service for CLI proxying, and the official Tor Browser for `.onion` access.
