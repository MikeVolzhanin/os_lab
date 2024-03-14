#!/bin/bash

# Функция для создания группы и добавления пользователей в неё
create_group() {
    local group=$1
    local users=$2

    # Создаем группу, если она не существует
    if ! grep -q "^$group:" /etc/group; then
        sudo groupadd "$group"
        echo "Group '$group' created."
    fi

    # Добавляем пользователей в группу
    IFS=',' read -ra user_list <<< "$users"
    for user in "${user_list[@]}"; do
        sudo usermod -aG "$group" "$user"
        echo "User '$user' added to group '$group'"
    done
}

# Функция для удаления группы
delete_group() {
    local group=$1

    # Проверяем существование группы
    if grep -q "^$group:" /etc/group; then
        sudo groupdel "$group"
        echo "Group '$group' deleted."
    else
        echo "Group '$group' does not exist."
    fi
}

# Функция для вывода справочной информации
show_help() {
    echo "Options:"
    echo "  -d    Delete specified groups instead of creating them."
    echo "  -help Display this help message."
    echo ""
    echo "Examples:"
    echo "  Create groups and add users:"
    echo "    group1:user1,user2"
    echo ""
    echo "  Delete groups:"
    echo "    group1,group2"
}

# Обработка атрибута -help
if [ "$1" = "-help" ]; then
    show_help
    exit 0
fi

# Обработка опции "-d" для удаления групп
if [ "$1" = "-d" ]; then
    shift
    # Считываем группы для удаления из стандартного ввода, разделенные запятыми
    IFS=',' read -ra groups
    # Перебираем группы и удаляем их
    for group in "${groups[@]}"; do
        delete_group "$group"
    done
    exit 0
fi

IFS=':'

# Считывание данных из стандартного ввода
while IFS= read -r arg; do
    # Разделение строки на переменные group и users
    read -r group users <<< "$arg"
    # Вызов функции create_group с аргументами group и users
    create_group "$group" "$users"
    exit 0
done

