#!/bin/bash

RED_COLOR="\e[31m"
GREEN_COLOR="\e[32m"
NO_COLOR="\e[0m"
SCRIPT_DIR="$(dirname "$0")"
OUTPUT_FILE="$SCRIPT_DIR/output-$(date +'%Y_%m_%d_%H-%M-%S').log"

systemctl status fail2ban.service

{
    # Проверяем существует ли fail2ban.log.
    if [ -f "$SCRIPT_DIR/fail2ban.log" ]; then
        echo -e "${GREEN_COLOR}Файл журнала fail2ban${NO_COLOR}"
        sudo tail "$SCRIPT_DIR/fail2ban.log"
    else
        echo -e "${RED_COLOR}Файл журнала fail2ban не найден${NO_COLOR}"
        exit 1
    fi

    # Получаем статус сервиса fail2ban sshd
    echo -e "${GREEN_COLOR}Получение статуса fail2ban для sshd${NO_COLOR}"
    sudo fail2ban-client status sshd || { echo -e "${RED_COLOR}Ошибка при получении статуса fail2ban для sshd${NO_COLOR}"; exit 1; }

# Перенаправление вывода скрипта в файл.
} | tee "$OUTPUT_FILE"
