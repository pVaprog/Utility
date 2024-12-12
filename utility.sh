# Функция для вывода справки
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -u, --users           List users and their home directories."
    echo "  -p, --processes       List running processes sorted by PID."
    echo "  -h, --help            Show this help message."
    echo "  -l PATH, --log PATH   Output to a log file instead of stdout."
    echo "  -e PATH, --errors PATH Redirect error messages to the specified file."
}

# Функция для обработки аргумента -u или --users
list_users() {
    getent passwd | cut -d: -f1,6 | sort
}

# Функция для обработки аргумента -p или --processes
list_processes() {
    ps -e --sort pid
}

# Функция для обработки файла логов
output_to_log() {
    local log_path="$1"
    if [ ! -d "$(dirname "$log_path")" ]; then
        echo "Error: Directory for log file '$log_path' does not exist." >&2
        exit 1
    fi
    exec > "$log_path" 2>&1
}

# Функция для обработки ошибок
output_errors_to_log() {
    local error_path="$1"
    if [ ! -d "$(dirname "$error_path")" ]; then
        echo "Error: Directory for error file '$error_path' does not exist." >&2
        exit 1
    fi
    exec 2> "$error_path"
}

# Обработка аргументов командной строки
while [[ $# -gt 0 ]]; do
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
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                log_file="$2"
                shift 2
            else
                echo "Error: Missing argument for -l|--log option." >&2
                exit 1
            fi
            ;;
        -e|--errors)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                error_file="$2"
                shift 2
            else
                echo "Error: Missing argument for -e|--errors option." >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown option '$1'." >&2
            print_help
            exit 1
            ;;
    esac
done

# Обработка вывода
if [ "$action_users" ]; then
    if [ -n "$log_file" ]; then
        output_to_log "$log_file"
    fi
    if [ -n "$error_file" ]; then
        output_errors_to_log "$error_file"
    fi
    list_users
fi

if [ "$action_processes" ]; then
    if [ -n "$log_file" ]; then
        output_to_log "$log_file"
    fi
    if [ -n "$error_file" ]; then
        output_errors_to_log "$error_file"
    fi
    list_processes
fi
