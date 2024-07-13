#!/bin/bash

echo -e "[CW] Contact: https://www.blog-cyberworm.com/blog/social-media"

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
    "burp-suite"
    "foremost"
    "exiftool"
    "hashcat"
    "netcat"
    "openssl"
    "johnny"
    "dirbuster"
    "dsniff"
    "dnsenum"
    "exploitdb"
    "maltego"
    "exploitdb-bin-sploits"
    "zaproxy"
    "nikto"
    "sqlninja"
    "dsniff"
    "dnsenum"
    "nbtscan"
    "snmpcheck"
    "ike-scan"
    "powersploit"
    "mitmproxy"
    "bettercap"
    "tcpflow"
    "ettercap"
    "zmap"
    "socat"
    "proxychains"
    "routersploit"
    "autopsy"
    "hashdeep"
    "chkrootkit"
    "lynis"
    "ossec-hids"
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
        read -p "Enter the number of the tool to select (or type 'done' to finish): " choice
        if [[ $choice == "done" ]]; then
            break
        elif [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 0 ] && [ $choice -lt ${#OPTIONAL_TOOLS[@]} ]; then
            selected_tools+=("${OPTIONAL_TOOLS[$choice]}")
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

install_selected_tools() {
    if [ ${#selected_tools[@]} -eq 0 ]; then
        echo "No tools selected."
        return
    fi

    echo "Installing selected tools..."
    for tool in "${selected_tools[@]}"; do
        sudo apt-get install -y "$tool"
    done
    echo "Installation complete."
}

install_github_repos() {
    local tools_dir="/opt/my_tools"
    mkdir -p "$tools_dir"
    cd "$tools_dir" || { echo "Failed to change directory to $tools_dir"; exit 1; }

    echo -e "\n[!] Tools are to be installed in $tools_dir.\n"
    sleep 3

    for repo in "${GITHUB_REPOS[@]}"; do
        git clone "$repo"
        echo -e "\n[*] $(basename "$repo") is installed.\n"
    done
}

install_vscode() {
    sudo apt-get install -y curl
    local url="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    local file="vscode.deb"
    curl -L -o "$file" "$url"
    sudo dpkg -i "$file"
    echo -e "\n[*] VS Code has been installed.\n"
}

install_sublime_text() {
    echo "Downloading Sublime Text 3..."
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo tee /etc/apt/sources.list.d/sublime-text.list <<< "deb https://download.sublimetext.com/ apt/stable/"
    sudo apt-get update
    sudo apt-get install -y sublime-text
    echo -e "\n[*] SublimeText has been installed.\n"
}

install_beef() {
    local beef_dir="/opt/beef"
    cd /opt || { echo "Failed to change directory to /opt"; exit 1; }

    echo -e "\n[*] Installing requirements..."
    sudo apt-get install -y ruby ruby-dev libsqlite3-dev libsqlite3-0
    sudo gem install bundler

    echo -e "\n[+] Installing BeEF..."
    git clone https://github.com/beefproject/beef.git "$beef_dir"
    cd "$beef_dir" || { echo "Failed to change directory to $beef_dir"; exit 1; }
    ./install
    echo -e "\n[+] BeEF has been installed.\n"
    echo -e "\n[WARN] You have to change the default username and password in the config.yaml file."
}

install_airgeddon() {
    local airgeddon_dir="/opt/airgeddon"
    cd /opt || { echo "Failed to change directory to /opt"; exit 1; }

    echo -e "\n[+] Installing Airgeddon..."
    git clone https://github.com/v1s1t0r1sh3r3/airgeddon.git "$airgeddon_dir"
    cd "$airgeddon_dir" || { echo "Failed to change directory to $airgeddon_dir"; exit 1; }
    ./airgeddon.sh
    echo -e "\n[+] Airgeddon has been installed.\n"
}

install_fatrat() {
    local fatrat_dir="/opt/TheFatRat"

    echo -e "\n[+] Installing The FatRat..."
    git clone https://github.com/screetsec/TheFatRat.git "$fatrat_dir"
    cd "$fatrat_dir" || { echo "Failed to change directory to $fatrat_dir"; exit 1; }
    chmod 777 setup.sh
    ./setup.sh
    echo -e "\n[+] TheFatRat has been installed.\n"
}

main_menu() {
    select options in "Upgrade your system" "Show optional tools" "Get the Github Repositories" "Get text editors (leafpad, gedit, and mousepad)" "Get VS Code" "Get SublimeText" "Get BeEF" "Get Airgeddon" "Get TheFatRat" "Exit"; do
        case $options in
            "Upgrade your system")
                sudo apt-get upgrade -y
                echo "[+] Done."
                ;;
            "Show optional tools")
                show_optional_tools
                collect_user_choices
                install_selected_tools
                echo "[+] Done."
                ;;
            "Get the Github Repositories")
                install_github_repos
                echo "[+] Done."
                ;;
            "Get text editors (leafpad, gedit, and mousepad)")
                sudo apt-get install -y leafpad gedit mousepad
                echo "[+] Done."
                ;;
            "Get VS Code")
                install_vscode
                echo "[+] Done."
                ;;
            "Get SublimeText")
                install_sublime_text
                echo "[+] Done."
                ;;
            "Get BeEF")
                install_beef
                echo "[+] Done."
                ;;
            "Get Airgeddon")
                install_airgeddon
                echo "[+] Done."
                ;;
            "Get TheFatRat")
                install_fatrat
                echo "[+] Done."
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

