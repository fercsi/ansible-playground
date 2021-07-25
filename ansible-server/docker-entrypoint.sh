#!/bin/bash

set -e

ANSIBLE_HOSTS=${ANSIBLE_HOSTS:-host1 host2 host3}
HOST_PASSWORD=${HOST_PASSWORD:-root}

IFS=' '
read -r -a hosts <<< "$ANSIBLE_HOSTS"

if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 2048 -N '' -f /root/.ssh/id_rsa
fi

if [ ! -f /var/run/ansible-playground ]; then
    echo "Add hosts to inventory: $ANSIBLE_HOSTS"
    for h in "${hosts[@]}"; do
        echo "$h:"
        ssh-keyscan -H $h >>/root/.ssh/known_hosts
        echo $HOST_PASSWORD | sshpass ssh-copy-id -f "root@$h"
        echo $h >>/etc/ansible/hosts
    done
    echo [$(date -Iseconds)] Inventory initialized. > /var/run/ansible-playground
fi

if [ ! -z "$ANSIBLE_HOSTS_FILE" ]; then
    cp "$ANSIBLE_HOSTS_FILE" /etc/ansible/hosts
fi

exec "$@"

