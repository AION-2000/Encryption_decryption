#!/bin/bash

# setup Bash environment
set -euo pipefail

# Function to check and install necessary tools
install_deps() {
    for dep in openssl shred gzip figlet lolcat; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "Installing $dep..."
            sudo apt-get update && sudo apt-get install -y "$dep" || brew install "$dep" || sudo yum install -y "$dep"
        fi
    done
}

# Define ANSI color codes
WHITE='\033[1;37m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m' # Reset to default color

# Banner Display with multi-color support
banner() {
    figlet -f slant "AION's Tool" | lolcat
    echo -e "${WHITE}Welcome to AION's Tool ${RESET}"
}

show_progress() {
  local -r msg="$1"
  local -i percent="$2"
  local -i completed=$((percent / 2))
  local -i remaining=$((50 - completed))
  printf "\r%s: [%-${completed}s%*s] %d%% Complete" "$msg" '' $remaining '' $percent
}

# Encryption Action
encrypt_file() {
    local input_file=$1
    local temp_file="${input_file}.enc"
    
    echo -e "${BLUE}Starting Encryption...${RESET}"
    # Simulating progress for aesthetic purposes
    for i in {1..10}; do
      sleep 0.5
      show_progress "Encrypting" $((i * 10))
    done
    echo
    
    # Actual encryption functionality
    gzip -c "$input_file" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 10000 -out "$temp_file"
    shred -u "$input_file"
    mv "$temp_file" "$input_file"

    echo -e "${YELLOW}The file has been encrypted and replaced: $input_file${RESET}"
}

# Decryption Action
decrypt_file() {
    local input_file=$1
    local temp_file="${input_file%.enc}.dec"

    echo -e "${RED}Starting Decryption...${RESET}"
    # Simulating progress for aesthetic purposes
    for i in {1..10}; do
      sleep 0.5
      show_progress "Decrypting" $((i * 10))
    done
    echo
    
    # Actual decryption functionality
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 10000 -in "$input_file" | gunzip > "$temp_file"
    shred -u "$input_file"
    mv "$temp_file" "${input_file%.enc}"

    echo -e "${YELLOW}The file has been decrypted and replaced: ${input_file%.enc}${RESET}"
}

# Main operation
main() {
    install_deps
    clear
    banner
    echo -e "\033[1;32m 1. Encrypt a File \033[0m\n\033[1;33m 2. Decrypt a File \033[0m"
    read -p "Enter a Choice: " choice
    echo " "
    read -p "Enter the file path: " file_path

    [[ -z "$file_path" || ! -e "$file_path" ]] && { echo "${RED}Invalid File Path.${RESET}"; exit 1; }

    if [[ "$choice" == "1" ]]; then
        encrypt_file "$file_path"
    elif [[ "$choice" == "2" ]]; then
        decrypt_file "$file_path"
    else
        echo "${RED}Invalid option. Please choose 1 or 2.${RESET}" ; exit 1
    fi
}

main "$@"
