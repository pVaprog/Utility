#!/bin/bash

print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --users           List users and their home directories."
    echo "  -p, --processes       List running processes sorted by PID."
    echo "  -h, --help            Show this help message."
    echo "  -l PATH, --log PATH   Output to a log file instead of stdout."
    echo "  -e PATH, --errors PATH Redirect error messages to the specified file."
}

# Определение длинных опций
OPTIONS=$(getopt -o uphl:e: --long users,processes,help,log:,errors: -- "$@")

# Проверка на ошибку
if [ $? -ne 0 ]; then
    print_help
    exit 1
fi

# Управление опциями, как аргументами, после getopt
eval set -- "$OPTIONS"

# Переменные для опций
action_users=false
action_processes=false
log_file=""
error_file=""

# Обработка аргументов командной строки
while true; do
    case "$1" in
        -u|--users)
            action_users=true
            shift
            ;;
        -p|--processes)
            action_processes=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -l|--log)
            log_file="$2"
            shift 2
            ;;
        -e|--errors)
            error_file="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error: Unknown option '$1'." >&2
            print_help
            exit 1
            ;;
    esac
done

# Обработка вывода
if [ -n "$log_file" ]; then
    exec > "$log_file" 2>&1
fi

if [ -n "$error_file" ]; then
    exec 2> "$error_file"
fi

if [ "$action_users" = true ]; then
    getent passwd | cut -d: -f1,6 | sort
fi

if [ "$action_processes" = true ]; then
    ps -e --sort pid
fi
