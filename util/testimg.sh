#!/bin/bash

set -e

function cleanup {
    if [[ "$cid" != "" ]]; then
        docker stop $cid >/dev/null
        docker rm $cid >/dev/null
    fi
    exit 1
}

trap cleanup ERR

image=$1

cid=$(docker run -d $image)
ipaddr=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' $cid)

# test ssh and python3
kernel=$(sshpass -p root ssh root@$ipaddr -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t 'uname -s' 2>/dev/null)
#>if [[ "$kernel" != "Linux" ]]; then
if [[ "${kernel:0:5}" != "Linux" ]]; then
    echo "TEST FAILED: Could not connect to server" 1>&2
    cleanup
fi
python=$(sshpass -p root ssh root@$ipaddr -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t 'python3 --version' 2>/dev/null)
if [[ "${python:0:8}" != "Python 3" ]]; then
    echo "TEST FAILED: Did not find Python 3" 1>&2
    cleanup
fi

docker stop $cid >/dev/null
docker rm $cid >/dev/null

echo "TEST SUCCESSFUL"
