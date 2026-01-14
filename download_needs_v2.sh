#!/bin/bash

echo -e "[CW] Contact: https://www.blog-cyberworm.com/blog/social-media"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "[-] Please run this script as root (sudo su)."
    exit 1
fi

GITHUB_REPOS=(
    "https://github.com/bellurm/wifi-connection-checker.git"
    "https://github.com/bellurm/Network-Scanner.git"
    "https://github.com/bellurm/Man-In-The-Middle-Attack.git"
    "https://github.com/bellurm/MAC-Changer.git"
    "https://github.com/bellurm/MITM-Detecter-v-Python.git"
    "https://github.com/bellurm/Reverse-Shell-Detecter.git"
    "https://github.com/bellurm/Deauth-Detecter.git"
    "https://github.com/bellurm/FindFileV2.git"
    "https://github.com/bellurm/File-Encrypter-Decrypter.git"
    "https://github.com/bellurm/Add-Linux-User.git"
    "https://github.com/bellurm/AADS.git"
    "https://github.com/bellurm/macchanger.git"
    "https://github.com/bellurm/Reverse-Shell-Detecter-vBash.git"
    "https://github.com/bellurm/BruteForce_UNIX.git"
    "https://github.com/bellurm/Monitoring-Directory.git"
    "https://github.com/bellurm/nmap-basics.git"
    "https://github.com/bellurm/cw-network-attacker.git"
    "https://github.com/bellurm/EmailSenderV2.git"
    "https://github.com/bellurm/AutoLoginv2.git"
    "https://github.com/bellurm/base64-decoder-vPython.git"
    "https://github.com/bellurm/base64-decoder-vShell.git"
    "https://github.com/bellurm/SimplePCAP.git"
)

OPTIONAL_TOOLS=(
    "htop"
    "vim"
    "git"
    "curl"
    "wget"
    "tree"
    "nmap"
    "tcpdump"
    "wireshark"
    "john"
    "hydra"
    "aircrack-ng"
    "metasploit-framework"
    "sqlmap"
    "gdb"
    "strace"
    "ltrace"
    "volatility"
    "burpsuite"
    "foremost"
    "exiftool"
    "hashcat"
    "netcat-openbsd"
    "openssl"
    "johnny"
    "dirbuster"
    "dsniff"
    "dnsenum"
    "nbtscan"
    "snmpcheck"
    "ike-scan"
    "mitmproxy"
    "bettercap"
    "tcpflow"
    "ettercap-common"
    "zmap"
    "socat"
    "proxychains4"
    "routersploit"
    "autopsy"
    "hashdeep"
    "chkrootkit"
    "lynis"
    "sleuthkit"
    "dc3dd"
    "gobuster"
    "cewl"
    "unicornscan"
    "airgeddon"
    "seclists"
)

selected_tools=()

show_optional_tools() {
    echo "Select the tools you want to install:"
    for i in "${!OPTIONAL_TOOLS[@]}"; do
        echo "$i) ${OPTIONAL_TOOLS[$i]}"
    done
}

collect_user_choices() {
    while true; do
        read -rp "Enter number (or 'done' to finish): " choice
        if [[ "$choice" == "done" ]]; then
            break
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice < ${#OPTIONAL_TOOLS[@]} )); then
            tool="${OPTIONAL_TOOLS[$choice]}"
            if [[ " ${selected_tools[*]} " != *" $tool "* ]]; then
                selected_tools+=("$tool")
                echo "[*] Added: $tool"
            else
                echo "[!] $tool is already selected."
            fi
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

install_selected_tools() {
    if (( ${#selected_tools[@]} == 0 )); then
        echo "No tools selected."
        return
    fi

    echo "[*] Running apt update..."
    apt-get update -y

    echo "[*] Installing selected tools..."
    for tool in "${selected_tools[@]}"; do
        echo "[*] Installing: $tool"
        apt-get install -y "$tool" || echo "[-] Failed to install $tool (skipping)."
    done
    echo "[+] Installation of selected tools complete."
}

install_github_repos() {
    local tools_dir="/opt/my_tools"
    mkdir -p "$tools_dir"
    cd "$tools_dir" || { echo "Failed to cd to $tools_dir"; exit 1; }

    echo -e "\n[!] Repositories will be cloned into $tools_dir.\n"
    sleep 2

    for repo in "${GITHUB_REPOS[@]}"; do
        dirname="$(basename "$repo" .git)"
        if [[ -d "$dirname" ]]; then
            echo "[=] $dirname already exists, skipping."
            continue
        fi
        git clone "$repo"
        echo -e "[*] $(basename "$repo") cloned.\n"
    done
}

install_vscode() {
    echo "[*] Installing VS Code..."
    apt-get update -y
    apt-get install -y curl

    local url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    local file="/tmp/vscode.deb"
    curl -L -o "$file" "$url"

    dpkg -i "$file" || apt-get install -f -y
    echo -e "\n[*] VS Code has been installed.\n"
}

install_sublime_text() {
    echo "[!] Sublime Text repo integration caused apt issues before."
    echo "[!] I strongly recommend installing it manually if really needed."
    echo "[!] This function is disabled to avoid breaking your package manager."
}

install_beef() {
    local beef_dir="/opt/beef"
    cd /opt || { echo "Failed to cd to /opt"; exit 1; }

    echo -e "\n[*] Installing requirements for BeEF..."
    apt-get update -y
    apt-get install -y ruby ruby-dev libsqlite3-dev libsqlite3-0 build-essential

    gem install bundler

    if [[ -d "$beef_dir" ]]; then
        echo "[=] $beef_dir already exists, skipping clone."
    else
        echo -e "\n[+] Cloning BeEF..."
        git clone https://github.com/beefproject/beef.git "$beef_dir"
    fi

    echo -e "\n[+] BeEF cloned to $beef_dir."
    echo "[!] Run it manually and change default credentials in config.yaml."
}

install_airgeddon() {
    local airgeddon_dir="/opt/airgeddon"
    cd /opt || { echo "Failed to cd to /opt"; exit 1; }

    if [[ -d "$airgeddon_dir" ]]; then
        echo "[=] Airgeddon already exists at $airgeddon_dir."
    else
        echo -e "\n[+] Cloning Airgeddon..."
        git clone https://github.com/v1s1t0r1sh3r3/airgeddon.git "$airgeddon_dir"
    fi

    echo -e "\n[+] Airgeddon is ready at $airgeddon_dir."
    echo "[!] Run ./airgeddon.sh manually when you want to use it."
}

install_fatrat() {
    local fatrat_dir="/opt/TheFatRat"
    cd /opt || { echo "Failed to cd to /opt"; exit 1; }

    if [[ -d "$fatrat_dir" ]]; then
        echo "[=] TheFatRat already exists at $fatrat_dir."
    else
        echo -e "\n[+] Cloning TheFatRat..."
        git clone https://github.com/screetsec/TheFatRat.git "$fatrat_dir"
    fi

    echo "[!] TheFatRat modifies a lot on the system. Run setup.sh manually when you are ready."
    echo "    cd $fatrat_dir && chmod +x setup.sh && ./setup.sh"
}

install_text_editors() {
    echo "[*] Installing text editors (gedit, mousepad)..."
    apt-get update -y
    apt-get install -y gedit mousepad || echo "[-] Failed to install some editors."
    echo "[+] Done."
}

main_menu() {
    echo
    echo "===== CW Tool Installer ====="
    PS3="Choose an option (1-10): "

    select options in \
        "Upgrade your system" \
        "Show & install optional tools" \
        "Get the Github Repositories" \
        "Get text editors (gedit, mousepad)" \
        "Get VS Code" \
        "Get SublimeText (disabled)" \
        "Get BeEF" \
        "Get Airgeddon" \
        "Get TheFatRat" \
        "Exit"
    do
        case $options in
            "Upgrade your system")
                apt-get update -y
                apt-get full-upgrade -y
                echo "[+] System upgrade complete."
                ;;
            "Show & install optional tools")
                show_optional_tools
                collect_user_choices
                install_selected_tools
                ;;
            "Get the Github Repositories")
                install_github_repos
                ;;
            "Get text editors (gedit, mousepad)")
                install_text_editors
                ;;
            "Get VS Code")
                install_vscode
                ;;
            "Get SublimeText (disabled)")
                install_sublime_text
                ;;
            "Get BeEF")
                install_beef
                ;;
            "Get Airgeddon")
                install_airgeddon
                ;;
            "Get TheFatRat")
                install_fatrat
                ;;
            "Exit")
                echo -e "\nExiting..."
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

main_menu
