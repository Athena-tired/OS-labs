#!/bin/bash

set -euo pipefail

DB="${TODO_DB:-./.todo.txt}"

cleanup() {
    [[ -f "$DB" ]] && rm -f "$DB"
    exit 1
}

trap cleanup SIGINT SIGTERM

touch "$DB" 2>/dev/null

case "${1:-help}" in
    add)
        TASK="${@:2}"
        if [ -z "$TASK" ]; then
            echo "Ошибка: текст задачи не указан" >&2
            exit 1
        fi
        echo "[ ] $TASK" >> "$DB"
        echo "Добавлено"
        ;;
    list)
        if [ ! -s "$DB" ]; then
            echo "Список пуст"
            exit 0
        fi
        i=1
        while read -r line; do
            echo "($i) $line"
            ((i++))
        done < "$DB"
        ;;
    done)
        if [ -z "$2" ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "Ошибка: номер задачи должен быть числом" >&2
            exit 1
        fi
        
        mapfile -t tasks < "$DB"
        number="$2"
        index=$((number - 1))
        
        if [ $index -lt 0 ] || [ $index -ge ${#tasks[@]} ]; then
            echo "Ошибка: неверный номер задачи" >&2
            exit 1
        fi
        
        tasks[$index]=$(echo "${tasks[$index]}" | sed 's/\[ \]/[x]/')
        printf "%s\n" "${tasks[@]}" > "$DB"
        echo "Отмечено"
        ;;
    help)
        cat <<EOF
Использование:
    $0 add <текст задачи>  - добавить новую задачу
    $0 list                - показать список задач
    $0 done <номер>        - отметить задачу как выполненную
    $0 help                - показать эту справку
EOF
        ;;
    clear)
	cleanup
	;;
    *)
        echo "Неизвестная команда: $1" >&2
        exit 1
        ;;
esac
