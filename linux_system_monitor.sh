#!/bin/bash
df -h --output=source,size,used,avail,pcent,target | grep '^/dev/' | column -t
set -e

GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

required_commands=("top" "free" "df" "ps" "awk" "grep" "column")

check_dependencies() {
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Error: Required command '$cmd' is not installed.${RESET}"
            exit 1
        fi
    done
}

print_header() {
    clear
    echo -e "${BOLD}${CYAN}=========================================${RESET}"
    echo -e "${BOLD}${CYAN}         Linux System Monitor            ${RESET}"
    echo -e "${BOLD}${CYAN}=========================================${RESET}"
    echo -e "Date: $(date)"
    echo
}

get_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    printf "${BOLD}${BLUE}CPU Usage:${RESET} ${GREEN}%.2f%%${RESET}\n" "$cpu_usage"
}

get_ram_usage() {
    total_ram=$(free -m | awk '/Mem:/ {print $2}')
    used_ram=$(free -m | awk '/Mem:/ {print $3}')
    free_ram=$(free -m | awk '/Mem:/ {print $4}')
    ram_percent=$((used_ram * 100 / total_ram))

    echo -e "${BOLD}${BLUE}RAM Usage:${RESET}"
    echo -e "Used: ${YELLOW}${used_ram} MB${RESET}"
    echo -e "Free: ${GREEN}${free_ram} MB${RESET}"
    echo -e "Total: ${CYAN}${total_ram} MB${RESET}"
    echo -e "Usage: ${RED}${ram_percent}%${RESET}"
}

get_disk_usage() {
    echo -e "${BOLD}${BLUE}Disk Usage:${RESET}"
    df -h --output=source,size,used,avail,pcent,target | grep '^/dev/' | column -t
}

get_running_processes() {
    echo -e "${BOLD}${BLUE}Top 10 Running Processes by Memory Usage:${RESET}"
    ps -eo pid,ppid,%mem,%cpu,cmd --sort=-%mem | head -n 11
}

main() {
    check_dependencies
    print_header
    get_cpu_usage
    echo
    get_ram_usage
    echo
    get_disk_usage
    echo
    get_running_processes
    echo
}

while true; do
    main
    sleep 2
done