# DownloaderV2

A Bash-based security workstation bootstrapper for Debian, Ubuntu, Kali Linux, and other APT-based Linux environments.

DownloaderV2 provides an interactive and command-line interface for installing common development and cybersecurity packages, cloning security projects, managing a curated collection of my GitHub repositories, installing Visual Studio Code, and performing optional system upgrades.

The project is designed to make rebuilding a Linux security laboratory or workstation faster while keeping potentially invasive third-party setup scripts under explicit user control.

---

## Features

- Interactive terminal menu
- Non-interactive CLI mode
- APT package installation
- Package availability checking
- Installed-package detection
- Single APT metadata refresh per session
- Graceful handling of unavailable packages
- Curated cybersecurity tool list
- Clone/update personal GitHub repositories
- Clone/update selected external security projects
- Existing Git repositories updated with `git pull --ff-only`
- Existing non-Git directories never overwritten
- Visual Studio Code repository setup
- Architecture detection for VS Code
- Optional text editor installation
- Optional full system upgrade
- Explicit confirmation before full upgrade
- Configurable repository directories
- Error reporting and exit status handling

---

## Requirements

DownloaderV2 is intended for APT-based Linux distributions.

Required:

```text
Bash
apt-get
apt-cache
dpkg
dpkg-query
```

Git is installed automatically when required for repository operations.

Most installation operations require root privileges.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/bellurm/DownloaderV2.git
cd DownloaderV2
```

Make the script executable:

```bash
chmod +x download_needs_v2.sh
```

Run it:

```bash
sudo ./download_needs_v2.sh
```

Do not use:

```text
chmod 777
```

The script only needs execute permission.

---

## Interactive Mode

Running the script without arguments opens the interactive menu:

```bash
sudo ./download_needs_v2.sh
```

Example:

```text
CW Tool Installer 3.0.0

1) Select and install APT tools
2) Clone/update bellurm GitHub repositories
3) Clone/update external security repositories
4) Install text editors (gedit, mousepad)
5) Install Visual Studio Code
6) Upgrade the system
7) List known APT tools
8) Exit
```

---

## Package Installation

Display the known package list:

```bash
./download_needs_v2.sh --list-tools
```

Install packages directly:

```bash
sudo ./download_needs_v2.sh \
    --install-tools nmap,tshark,git
```

Multiple package names are separated with commas.

Before installation, DownloaderV2 checks whether each package:

1. Is already installed
2. Exists in the configured APT repositories

Unavailable packages are skipped rather than causing the entire installation session to fail.

---

## Distribution-Specific Packages

The package list includes tools commonly found across Debian, Ubuntu, Kali Linux, and security-focused repositories.

Examples include:

```text
nmap
tcpdump
wireshark
tshark
john
hydra
aircrack-ng
sqlmap
gdb
strace
hashcat
mitmproxy
bettercap
gobuster
lynis
sleuthkit
```

Some packages such as:

```text
metasploit-framework
burpsuite
routersploit
airgeddon
```

may not be present in every Debian or Ubuntu repository configuration.

DownloaderV2 checks package availability before attempting installation.

---

## Personal Repository Management

Clone the curated bellurm repository collection:

```bash
sudo ./download_needs_v2.sh \
    --clone-cw-repos
```

Default destination:

```text
/opt/cw-tools
```

The collection includes projects such as:

```text
Network-Scanner
Man-In-The-Middle-Attack
MAC-Changer
Reverse-Shell-Detecter
Deauth-Detecter
File-Encrypter-Decrypter
add_or_del_user_v2
AADS
nmap-basics
EmailSenderV2
SimplePCAP
Monitoring-Directory
Backup-System
```

---

## Existing Repositories

If a repository does not exist locally:

```text
git clone
```

is used.

If the directory already contains a Git repository:

```text
git pull --ff-only
```

is used instead.

DownloaderV2 does not automatically overwrite local changes or force-reset repositories.

If a destination exists but is not a Git repository, it is skipped.

---

## Custom Repository Directory

Use a different location:

```bash
sudo ./download_needs_v2.sh \
    --cw-dir /opt/my-tools \
    --clone-cw-repos
```

---

## External Security Projects

DownloaderV2 can clone selected external security repositories.

Currently supported:

```text
beef
airgeddon
```

Clone both:

```bash
sudo ./download_needs_v2.sh \
    --clone-external beef,airgeddon
```

Default destination:

```text
/opt/security-tools
```

External repositories are only cloned or updated.

DownloaderV2 does **not** automatically execute their installers, setup scripts, dependency installers, or configuration scripts.

This keeps third-party system modifications under explicit user control.

---

## Custom External Repository Directory

```bash
sudo ./download_needs_v2.sh \
    --external-dir /opt/lab-tools \
    --clone-external beef
```

---

## Visual Studio Code

Install Visual Studio Code:

```bash
sudo ./download_needs_v2.sh \
    --install-vscode
```

The script:

1. Detects the Debian architecture
2. Installs `wget` and `gpg` when required
3. Downloads Microsoft's signing key
4. Creates the VS Code APT source
5. Refreshes APT metadata
6. Installs the `code` package

Supported architectures:

```text
amd64
arm64
armhf
```

---

## Text Editors

Install:

```text
gedit
mousepad
```

with:

```bash
sudo ./download_needs_v2.sh \
    --install-editors
```

If one of the packages is unavailable in the configured repositories, it is skipped.

---

## System Upgrade

Run an optional full system upgrade:

```bash
sudo ./download_needs_v2.sh \
    --upgrade-system
```

DownloaderV2 asks for confirmation before executing:

```text
apt-get full-upgrade
```

Example:

```text
This will run a full system upgrade. Continue? [y/N]
```

The default response is No.

---

## Combining Actions

Several operations can be requested in the same command.

Example:

```bash
sudo ./download_needs_v2.sh \
    --install-tools git,nmap,tshark \
    --clone-cw-repos
```

Or:

```bash
sudo ./download_needs_v2.sh \
    --install-editors \
    --install-vscode
```

---

## Repository Workflow

```text
Repository requested
        │
        ▼
Destination exists?
        │
        ├── No
        │    │
        │    ▼
        │  git clone
        │
        ▼
       Yes
        │
        ▼
Git repository?
        │
        ├── No ──► Skip safely
        │
        ▼
       Yes
        │
        ▼
git pull --ff-only
        │
        ▼
Updated repository
```

---

## Package Workflow

```text
Tool selected
     │
     ▼
APT metadata
     │
     ▼
Already installed?
     │
     ├── Yes ──► Skip
     │
     ▼
     No
     │
     ▼
Available in repository?
     │
     ├── No ──► Warn and skip
     │
     ▼
     Yes
     │
     ▼
apt-get install
```

---

## Safety Design

DownloaderV2 intentionally avoids several aggressive automation patterns.

It does not:

- Use `chmod 777`
- Force-reset existing Git repositories
- Delete conflicting directories
- Execute cloned third-party setup scripts
- Automatically run external exploitation frameworks
- Automatically perform a full system upgrade without confirmation
- Assume every security package exists on every Linux distribution

---

## What This Project Demonstrates

DownloaderV2 demonstrates practical knowledge of:

- Bash scripting
- Linux system administration
- APT package management
- Git automation
- Repository lifecycle management
- Input validation
- Interactive CLI design
- Non-interactive CLI design
- Error handling
- Debian package architecture
- Linux workstation provisioning
- Security tooling
- System automation

---

## Limitations

DownloaderV2 is designed specifically for APT-based Linux systems.

Package availability depends on:

- Linux distribution
- Distribution version
- Configured repositories
- CPU architecture

The project does not attempt to automatically add third-party security repositories for every unavailable security tool.

External security projects may also require additional dependencies or configuration after being cloned.

Always consult the official documentation of third-party projects before running their installation scripts.

---

## Responsible Use

DownloaderV2 can install or clone software commonly used in cybersecurity laboratories and authorized penetration testing.

The presence of a tool in this installer does not imply authorization to use it against third-party systems.

Use security tooling only in:

- Systems you own
- Personal laboratories
- CTF environments
- Authorized security assessments
- Networks for which you have explicit permission

---

## Author

**Cyber Worm**

GitHub: [@bellurm](https://github.com/bellurm)
