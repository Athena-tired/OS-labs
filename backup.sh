#!/bin/bash

set -euo pipefail

cleanup() {
	[[ -f "$TMP_FILE" ]] && rm -f "$TMP_FILE"
	exit 1
}

trap cleanup SIGINT SIGTERM

if [ "$#" -ne 1 ]; then
	echo "Использование: ./backup.sh путь/к/каталогу" >&2
	exit 1
fi

DIR="$1"

if [ ! -e "$DIR" ]; then
	echo "'$DIR' - файл или несуществующий каталог" >&2
	exit  1
fi

TIME=$(date +"%Y%m%d_%H%M%S")
TMP_FILE="./tmp/backup_${TIME}.part"
FINAL_FILE="./tmp/backup_${TIME}.tar.gz"

echo "Архивирую ${DIR} -> ${FINAL_FILE}"

tar czf "$TMP_FILE" "$DIR" 2>/dev/null

if [ $? -ne 0 ] || [ ! -s "$TMP_FILE" ]; then
	echo "Ошибка при создании архива" >&2
	cleanup
	exit 1
fi

mv "$TMP_FILE" "$FINAL_FILE"

echo "Готово: ${FINAL_FILE}"
