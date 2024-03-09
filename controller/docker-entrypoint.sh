#!/bin/bash

set -e

APG_HOSTS=${APG_HOSTS:-host1 host2 host3}
APG_HOST_PASSWORD=${APG_HOST_PASSWORD:-root}

IFS=' '
read -r -a hosts <<< "$APG_HOSTS"

if [ ! -f /root/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_rsa
fi

if [ ! -f /var/run/ansible-playground ]; then
    echo "Add hosts to inventory: $APG_HOSTS"
    mkdir -p /etc/ansible
    for h in "${hosts[@]}"; do
        echo "$h:"
        ssh-keyscan -H $h >>/root/.ssh/known_hosts
        echo $APG_HOST_PASSWORD | sshpass ssh-copy-id -f "root@$h"
        echo $h >>/etc/ansible/hosts
    done
    echo [$(date -Iseconds)] Inventory initialized. > /var/run/ansible-playground
fi

if [ ! -z "$APG_HOSTS_FILE" ]; then
    cp "$APG_HOSTS_FILE" /etc/ansible/hosts
fi

exec "$@"
