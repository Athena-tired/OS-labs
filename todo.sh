#!/bin/bash

set -euo pipefail

DB="${TODO_DB:-./.todo.txt}"

trap 'exit 1' SIGINT SIGTERM

touch "$DB" 2>/dev/null

case "${1:-help}" in
    add)
        TASK="${@:2}"
        if [ -z "$TASK" ]; then
            echo "Текст задачи не указан" >&2
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
            echo "$i) $line"
            ((i++))
        done < "$DB"
        ;;
    done)
        if [ -z "$2" ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "Номер задачи должен быть числом" >&2
            exit 1
        fi
        
        mapfile -t tasks < "$DB"
        number="$2"
        index=$((number - 1))
        
        if [ $index -lt 0 ] || [ $index -ge ${#tasks[@]} ]; then
            echo "Неверный номер задачи" >&2
            exit 1
        fi
        
        tasks[$index]=$(echo "${tasks[$index]}" | sed 's/\[ \]/[x]/')
        printf "%s\n" "${tasks[@]}" > "$DB"
        echo "Отмечено"
        ;;
    help)
        cat <<EOF
Использование:
    ./todo.sh add <текст задачи>  - добавить новую задачу
    ./todo.sh list                - показать список задач
    ./todo.sh done <номер>        - отметить задачу как выполненную
    ./todo.sh help                - показать эту справку
EOF
        ;;
    clear)
		[[ -f "$DB" ]] && rm -f "$DB"
		echo "Список очищен"
		;;
    *)
        echo "Неизвестная команда: $1" >&2
        exit 1
        ;;
esac
