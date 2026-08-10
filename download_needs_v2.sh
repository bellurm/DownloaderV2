#!/usr/bin/env bash

set -u -o pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
umask 022

PROGRAM_NAME="CW Tool Installer"
VERSION="3.0.0"

CW_TOOLS_DIR="/opt/cw-tools"
EXTERNAL_TOOLS_DIR="/opt/security-tools"

APT_UPDATED=0


CW_REPOS=(
    "https://github.com/bellurm/Network-Scanner.git"
    "https://github.com/bellurm/Man-In-The-Middle-Attack.git"
    "https://github.com/bellurm/MAC-Changer.git"
    "https://github.com/bellurm/Reverse-Shell-Detecter.git"
    "https://github.com/bellurm/Deauth-Detecter.git"
    "https://github.com/bellurm/File-Encrypter-Decrypter.git"
    "https://github.com/bellurm/add_or_del_user_v2.git"
    "https://github.com/bellurm/AADS.git"
    "https://github.com/bellurm/nmap-basics.git"
    "https://github.com/bellurm/EmailSenderV2.git"
    "https://github.com/bellurm/SimplePCAP.git"
    "https://github.com/bellurm/Monitoring-Directory.git"
    "https://github.com/bellurm/Backup-System.git"
)


APT_TOOLS=(
    "htop"
    "vim"
    "git"
    "curl"
    "wget"
    "tree"
    "nmap"
    "tcpdump"
    "wireshark"
    "tshark"
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


EXTERNAL_REPO_NAMES=(
    "beef"
    "airgeddon"
)


EXTERNAL_REPO_URLS=(
    "https://github.com/beefproject/beef.git"
    "https://github.com/v1s1t0r1sh3r3/airgeddon.git"
)


info() {
    printf '[INFO] %s\n' "$*"
}


ok() {
    printf '[OK] %s\n' "$*"
}


warn() {
    printf '[WARN] %s\n' "$*" >&2
}


error() {
    printf '[ERROR] %s\n' "$*" >&2
}


fatal() {
    error "$*"
    exit 2
}


usage() {
    cat <<'USAGE'
CW Tool Installer - Debian-based security workstation bootstrapper

Usage:
  download_needs_v2.sh
  download_needs_v2.sh [options]

Options:
      --list-tools
          List known APT package names.

      --install-tools LIST
          Install comma-separated package names.

      --clone-cw-repos
          Clone or update bellurm repositories.

      --clone-external LIST
          Clone or update external repositories.
          Supported names: beef, airgeddon

      --install-editors
          Install gedit and mousepad when available.

      --install-vscode
          Configure Microsoft's VS Code APT repository
          and install Visual Studio Code.

      --upgrade-system
          Run apt-get update and apt-get full-upgrade.

      --cw-dir DIR
          Destination for bellurm repositories.
          Default: /opt/cw-tools

      --external-dir DIR
          Destination for external repositories.
          Default: /opt/security-tools

  -V, --version
          Show version information.

  -h, --help
          Show this help message.

Examples:
  sudo ./download_needs_v2.sh

  sudo ./download_needs_v2.sh \
      --install-tools nmap,tshark,git

  sudo ./download_needs_v2.sh \
      --clone-cw-repos

  sudo ./download_needs_v2.sh \
      --clone-external beef,airgeddon
USAGE
}


require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        fatal \
            "This action requires root privileges. Run the script with sudo."
    fi
}


require_debian_tools() {
    local command_name

    for command_name in \
        apt-get \
        apt-cache \
        dpkg \
        dpkg-query
    do
        command -v "$command_name" >/dev/null 2>&1 ||
            fatal \
                "Required Debian/Ubuntu package tool not found: $command_name"
    done
}


apt_update_once() {
    require_root
    require_debian_tools

    if (( APT_UPDATED == 1 )); then
        return 0
    fi

    info "Refreshing APT package metadata..."

    if ! apt-get update; then
        error "apt-get update failed."
        return 1
    fi

    APT_UPDATED=1
}


is_known_tool() {
    local requested="$1"
    local tool

    for tool in "${APT_TOOLS[@]}"; do
        if [[ "$tool" == "$requested" ]]; then
            return 0
        fi
    done

    return 1
}


package_installed() {
    local package="$1"

    [[ "$(
        dpkg-query \
            -W \
            -f='${Status}' \
            "$package" \
            2>/dev/null ||
        true
    )" == "install ok installed" ]]
}


package_available() {
    apt-cache show "$1" >/dev/null 2>&1
}


install_packages() {
    local package

    local failed=0
    local installed_count=0
    local skipped_count=0

    if (( $# == 0 )); then
        warn "No packages selected."
        return 0
    fi

    apt_update_once || return 1

    for package in "$@"; do

        if package_installed "$package"; then
            info "$package is already installed."
            (( skipped_count++ ))
            continue
        fi

        if ! package_available "$package"; then
            warn \
                "$package is not available in the configured APT repositories; skipping."

            (( skipped_count++ ))
            continue
        fi

        info "Installing $package..."

        if DEBIAN_FRONTEND=noninteractive \
            apt-get install -y "$package"
        then
            (( installed_count++ ))
        else
            error "Installation failed: $package"
            failed=1
        fi

    done

    info \
        "Package summary: installed=$installed_count skipped=$skipped_count"

    (( failed == 0 ))
}


list_tools() {
    local i

    printf 'Known APT package names:\n\n'

    for i in "${!APT_TOOLS[@]}"; do
        printf \
            '%2d) %s\n' \
            "$((i + 1))" \
            "${APT_TOOLS[$i]}"
    done

    printf '\n'
    printf \
        'Availability depends on the configured Debian/Ubuntu/Kali repositories.\n'
}


collect_package_selection() {
    local input=""
    local token=""
    local index=0
    local tool=""

    local -A selected=()

    list_tools

    printf '\n'
    printf \
        'Enter numbers separated by spaces, "all", or "done".\n'

    while true; do

        read -r -p '> ' input || return 1

        if [[ "$input" == "done" ]]; then
            break
        fi

        if [[ "$input" == "all" ]]; then
            SELECTED_PACKAGES=(
                "${APT_TOOLS[@]}"
            )

            return 0
        fi

        for token in $input; do

            if [[ ! "$token" =~ ^[0-9]+$ ]]; then
                warn \
                    "Ignoring invalid selection: $token"
                continue
            fi

            index=$((10#$token - 1))

            if (
                ((
                    index < 0 ||
                    index >= ${#APT_TOOLS[@]}
                ))
            ); then
                warn \
                    "Selection out of range: $token"
                continue
            fi

            tool="${APT_TOOLS[$index]}"

            selected["$tool"]=1
        done

        info \
            "Selected ${#selected[@]} package(s). Type more numbers or 'done'."

    done

    SELECTED_PACKAGES=()

    for tool in "${APT_TOOLS[@]}"; do
        if [[ -n "${selected[$tool]:-}" ]]; then
            SELECTED_PACKAGES+=(
                "$tool"
            )
        fi
    done
}


ensure_git() {
    if command -v git >/dev/null 2>&1; then
        return 0
    fi

    install_packages git
}


clone_or_update_repo() {
    local url="$1"
    local destination_root="$2"

    local name=""
    local destination=""

    name="$(
        basename "$url" .git
    )"

    destination="${
        destination_root%/
    }/$name"

    if [[ -d "$destination/.git" ]]; then

        info "Updating $name..."

        if git \
            -C "$destination" \
            pull \
            --ff-only
        then
            ok "$name is up to date."
        else
            warn \
                "Could not fast-forward $name; existing working tree was left unchanged."

            return 1
        fi

        return 0
    fi

    if [[ -e "$destination" ]]; then

        warn \
            "$destination exists but is not a Git repository; skipping."

        return 1
    fi

    info "Cloning $name..."

    if git clone \
        "$url" \
        "$destination"
    then
        ok \
            "Cloned $name -> $destination"
    else
        error \
            "Clone failed: $url"

        return 1
    fi
}


clone_cw_repositories() {
    local repo

    local failed=0

    require_root

    ensure_git ||
        return 1

    mkdir \
        -p \
        -- \
        "$CW_TOOLS_DIR" ||
        fatal \
            "Could not create $CW_TOOLS_DIR"

    for repo in "${CW_REPOS[@]}"; do

        clone_or_update_repo \
            "$repo" \
            "$CW_TOOLS_DIR" ||
            failed=1

    done

    (( failed == 0 ))
}


external_repo_url() {
    local requested="$1"
    local i

    for i in "${!EXTERNAL_REPO_NAMES[@]}"; do

        if [[
            "${EXTERNAL_REPO_NAMES[$i]}" ==
            "$requested"
        ]]; then

            printf \
                '%s\n' \
                "${EXTERNAL_REPO_URLS[$i]}"

            return 0
        fi

    done

    return 1
}


clone_external_repositories() {
    local name
    local url=""

    local failed=0

    require_root

    ensure_git ||
        return 1

    mkdir \
        -p \
        -- \
        "$EXTERNAL_TOOLS_DIR" ||
        fatal \
            "Could not create $EXTERNAL_TOOLS_DIR"

    for name in "$@"; do

        if ! url="$(
            external_repo_url "$name"
        )"; then

            warn \
                "Unknown external repository: $name"

            failed=1
            continue
        fi

        clone_or_update_repo \
            "$url" \
            "$EXTERNAL_TOOLS_DIR" ||
            failed=1

    done

    info \
        "External repositories are cloned only; third-party setup scripts are not executed automatically."

    (( failed == 0 ))
}


install_editors() {
    install_packages \
        gedit \
        mousepad
}


install_vscode() {
    local architecture=""
    local key_tmp=""

    local source_file="/etc/apt/sources.list.d/vscode.sources"
    local key_file="/usr/share/keyrings/microsoft.gpg"

    require_root
    require_debian_tools

    architecture="$(
        dpkg --print-architecture
    )"

    case "$architecture" in
        amd64|arm64|armhf)
            ;;
        *)
            fatal \
                "VS Code repository is not configured by this script for architecture: $architecture"
            ;;
    esac

    install_packages \
        wget \
        gpg ||
        return 1

    key_tmp="$(
        mktemp
    )" ||
        fatal \
            "Could not create temporary file."

    info \
        "Installing Microsoft's VS Code signing key..."

    if ! wget \
        -qO \
        "$key_tmp" \
        "https://packages.microsoft.com/keys/microsoft.asc"
    then
        error \
            "Could not download Microsoft's signing key."

        rm \
            -f \
            -- \
            "$key_tmp"

        return 1
    fi

    if ! gpg \
        --batch \
        --yes \
        --dearmor \
        --output "$key_file" \
        "$key_tmp"
    then
        error \
            "Could not install Microsoft's signing key."

        rm \
            -f \
            -- \
            "$key_tmp"

        return 1
    fi

    chmod \
        0644 \
        "$key_file"

    rm \
        -f \
        -- \
        "$key_tmp"

    cat > "$source_file" <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: $architecture
Signed-By: $key_file
EOF

    APT_UPDATED=0

    apt_update_once ||
        return 1

    info \
        "Installing Visual Studio Code..."

    if DEBIAN_FRONTEND=noninteractive \
        apt-get install -y code
    then
        ok \
            "Visual Studio Code installed."
    else
        error \
            "Visual Studio Code installation failed."

        return 1
    fi
}


upgrade_system() {
    local answer=""

    require_root
    require_debian_tools

    printf \
        'This will run a full system upgrade. Continue? [y/N] '

    read -r answer

    case "$answer" in

        y|Y|yes|YES)

            apt_update_once ||
                return 1

            DEBIAN_FRONTEND=noninteractive \
                apt-get full-upgrade -y
            ;;

        *)

            info \
                "System upgrade cancelled."
            ;;

    esac
}


parse_csv_tools() {
    local csv="$1"

    local -a raw=()

    local item=""

    IFS=',' \
        read \
        -r \
        -a raw \
        <<< "$csv"

    PARSED_ITEMS=()

    for item in "${raw[@]}"; do

        item="${
            item//[[:space:]]/
        }"

        [[ -n "$item" ]] ||
            continue

        PARSED_ITEMS+=(
            "$item"
        )

    done
}


install_named_tools() {
    local name

    local -a validated=()

    for name in "$@"; do

        if is_known_tool "$name"; then

            validated+=(
                "$name"
            )

        else

            warn \
                "Unknown tool name: $name"

        fi

    done

    if (( ${#validated[@]} == 0 )); then

        error \
            "No valid package names were supplied."

        return 1
    fi

    install_packages \
        "${validated[@]}"
}


show_status() {
    local distribution="unknown"

    if [[ -r /etc/os-release ]]; then

        distribution="$(
            (
                . /etc/os-release
                printf \
                    '%s' \
                    "${PRETTY_NAME:-unknown}"
            )
        )"

    fi

    printf '\n'
    printf \
        '%s %s\n' \
        "$PROGRAM_NAME" \
        "$VERSION"

    printf \
        'CW repositories:       %s\n' \
        "$CW_TOOLS_DIR"

    printf \
        'External repositories: %s\n' \
        "$EXTERNAL_TOOLS_DIR"

    printf \
        'Distribution:          %s\n' \
        "$distribution"

    printf '\n'
}


main_menu() {
    local option=""
    local external_choice=""

    require_root
    require_debian_tools

    while true; do

        show_status

        cat <<'MENU'
1) Select and install APT tools
2) Clone/update bellurm GitHub repositories
3) Clone/update external security repositories
4) Install text editors (gedit, mousepad)
5) Install Visual Studio Code
6) Upgrade the system
7) List known APT tools
8) Exit
MENU

        read \
            -r \
            -p 'Choose an option [1-8]: ' \
            option

        case "$option" in

            1)

                SELECTED_PACKAGES=()

                collect_package_selection ||
                    continue

                if (
                    ((
                        ${#SELECTED_PACKAGES[@]} > 0
                    ))
                ); then

                    install_packages \
                        "${SELECTED_PACKAGES[@]}"

                else

                    info \
                        "No packages selected."

                fi
                ;;

            2)

                clone_cw_repositories
                ;;

            3)

                printf \
                    'Available: beef, airgeddon\n'

                read \
                    -r \
                    -p 'Enter comma-separated names (or "all"): ' \
                    external_choice

                if [[ "$external_choice" == "all" ]]; then

                    clone_external_repositories \
                        "${EXTERNAL_REPO_NAMES[@]}"

                else

                    parse_csv_tools \
                        "$external_choice"

                    clone_external_repositories \
                        "${PARSED_ITEMS[@]}"

                fi
                ;;

            4)

                install_editors
                ;;

            5)

                install_vscode
                ;;

            6)

                upgrade_system
                ;;

            7)

                list_tools
                ;;

            8)

                info \
                    "Exiting."

                return 0
                ;;

            *)

                warn \
                    "Invalid option."
                ;;

        esac

        printf '\nPress Enter to continue...'
        read -r _

    done
}


main() {
    local action_taken=0

    local install_tools_csv=""
    local external_csv=""

    local do_clone_cw=0
    local do_editors=0
    local do_vscode=0
    local do_upgrade=0
    local do_list=0

    local overall_status=0

    while (( $# > 0 )); do

        case "$1" in

            --list-tools)

                do_list=1
                action_taken=1
                shift
                ;;

            --install-tools)

                (( $# >= 2 )) ||
                    fatal \
                        "$1 requires a comma-separated list."

                install_tools_csv="$2"

                action_taken=1

                shift 2
                ;;

            --clone-cw-repos)

                do_clone_cw=1
                action_taken=1

                shift
                ;;

            --clone-external)

                (( $# >= 2 )) ||
                    fatal \
                        "$1 requires a comma-separated list."

                external_csv="$2"

                action_taken=1

                shift 2
                ;;

            --install-editors)

                do_editors=1
                action_taken=1

                shift
                ;;

            --install-vscode)

                do_vscode=1
                action_taken=1

                shift
                ;;

            --upgrade-system)

                do_upgrade=1
                action_taken=1

                shift
                ;;

            --cw-dir)

                (( $# >= 2 )) ||
                    fatal \
                        "$1 requires a directory."

                CW_TOOLS_DIR="$2"

                shift 2
                ;;

            --external-dir)

                (( $# >= 2 )) ||
                    fatal \
                        "$1 requires a directory."

                EXTERNAL_TOOLS_DIR="$2"

                shift 2
                ;;

            -V|--version)

                printf \
                    '%s %s\n' \
                    "$PROGRAM_NAME" \
                    "$VERSION"

                return 0
                ;;

            -h|--help)

                usage
                return 0
                ;;

            *)

                fatal \
                    "Unknown option: $1"
                ;;

        esac

    done

    if (( action_taken == 0 )); then

        main_menu
        return $?

    fi

    if (( do_list == 1 )); then
        list_tools
    fi

    if [[ -n "$install_tools_csv" ]]; then

        require_root

        parse_csv_tools \
            "$install_tools_csv"

        install_named_tools \
            "${PARSED_ITEMS[@]}" ||
            overall_status=1

    fi

    if (( do_clone_cw == 1 )); then

        clone_cw_repositories ||
            overall_status=1

    fi

    if [[ -n "$external_csv" ]]; then

        require_root

        parse_csv_tools \
            "$external_csv"

        clone_external_repositories \
            "${PARSED_ITEMS[@]}" ||
            overall_status=1

    fi

    if (( do_editors == 1 )); then

        require_root

        install_editors ||
            overall_status=1

    fi

    if (( do_vscode == 1 )); then

        install_vscode ||
            overall_status=1

    fi

    if (( do_upgrade == 1 )); then

        upgrade_system ||
            overall_status=1

    fi

    return "$overall_status"
}


main "$@"
