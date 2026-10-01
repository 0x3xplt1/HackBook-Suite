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
- Security tools via `pipx`: `impacket`, `pypykatz`, `oletools`, `h8mail`, `xortool`, `wpscan`, and more
- Go tools: `ffuf`, `gobuster`, `aquatone`, `subfinder`, etc.
- `nano` with syntax highlighting (includes MIPS Assembly)
- Mars4_5 MIPS simulator
- ZSH with `ubunly` theme + autosuggestions + fast-syntax-highlighting
- `xbar` and `Stats` for menu-bar monitoring
- `~/DockerLabs` folder structure for Docker file sharing

---

## Standalone Tools (Non-Homebrew)

These tools aren't in Homebrew or need special setup to work correctly on macOS.

### smtp-user-enum

The original Perl script from pentestmonkey — the same one Kali ships. Flags like `-M`, `-U`, `-t` work exactly as written in HTB writeups.

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

### emailharvester

The dedicated Kali Linux package for finding domain emails in search engines. Handled automatically by the GitHub tools script (cloned, requirements installed, and symlinked).

```bash
emailharvester -d example.com -e google
```

---

### xorsearch

Didier Stevens' XOR/ROT string scanner — standard in Kali and REMnux for malware analysis. Searches inside binary files for encoded strings like URLs, IPs, or shellcode. Not on Homebrew, so build it from source (takes about 5 seconds):

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

## macOS vs Kali — Command Parity

macOS is BSD-based, so several standard Linux tools are either missing or behave differently. The toolkit installs the GNU versions via Homebrew and maps them so copy-pasted Kali commands just work:

| Command | What it does |
|---------|-------------|
| `sed` | Aliased to `gsed`. Fixes `-i` in-place editing errors on macOS |
| `strings` | Aliased to `gstrings` (binutils). Reads ELF binaries correctly |
| `nc` | Wrapped with `rlwrap`. Adds arrow keys and history to reverse shells |
| `ftp` / `telnet` | Restored via `inetutils` (Apple removed them in High Sierra) |
| `mysql` | Aliased to `mariadb` (see below) |

### mysql → mariadb

Modern Oracle MySQL (v8.4+) dropped `mysql_native_password` and `--ssl=0`. A lot of older HTB targets rely on both. Kali quietly routes `mysql` through MariaDB to stay compatible — this toolkit does the same:

```bash
alias mysql="mariadb"
```

Copy-paste `mysql` commands from writeups and they work.

---

## Docker Labs 🐳

Pre-configured containers for Kali, Parrot OS, and REMnux. Each one gets `NET_ADMIN` capabilities, VPN tunnel access, VNC ports, and a shared folder mounted from your Mac.

```bash
kali-linux-lab       # Kali Linux
parrot-os-lab        # Parrot OS
remnux-lab           # REMnux (malware analysis)
```

Containers are temporary by default — removed on exit.

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
