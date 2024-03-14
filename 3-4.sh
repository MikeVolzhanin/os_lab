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
    echo "Usage: $0 [-d] <group>:<list-of-users> [<group>:<list-of-users> ...]"
    echo "Options:"
    echo "  -d    Delete specified groups instead of creating them."
    echo "  -help Display this help message."
    echo ""
    echo "Examples:"
    echo "  Create groups and add users:"
    echo "    $0 group1:user1,user2 group2:user3,user4"
    echo ""
    echo "  Delete groups:"
    echo "    $0 -d group1 group2"
}

# Проверка наличия аргументов
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Обработка атрибута -help
if [ "$1" = "-help" ]; then
    show_help
    exit 0
fi

# Обработка опции "-d" для удаления групп
if [ "$1" = "-d" ]; then
    shift
    for arg; do
        IFS=':' read -r group _ <<< "$arg"
        delete_group "$group"
    done
    exit 0
fi

# Обработка входных данных для создания групп
for arg; do
    IFS=':' read -r group users <<< "$arg"
    create_group "$group" "$users"
done

