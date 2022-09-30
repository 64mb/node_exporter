#!/bin/bash

if test -f ".env"; then
    export $(cat ./.env | awk '!/^#/' | xargs)
fi

HOST=$1
NODE_DIR=/

alias ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias scp='scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

if [ ! -z "$SSH_PRIVATE_KEY" ]; then
    echo "init ssh agent..."

    eval $(ssh-agent -s)
    echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add "-"
fi

echo "install node_exporter to host..."

# KEY=$(cat ./.ssh/id_rsa.pub)
ssh root@"$HOST" 'mkdir -p /tmp/node_exporter'

# tls for every domain
# scp ./node_exporter/setup.sh \
#     ./node_exporter/node_exporter.service \
#     ./node_exporter/web.yml \
#     ./.tls/server-cert.pem \
#     ./.tls/server-key.pem \
#     ./.tls/ca.pem \
#     root@"$HOST":/tmp/node_exporter

sed "s|{{HT_PASSWD_NODE_EXPORTER}}|"${HT_PASSWD_NODE_EXPORTER}"|" ./config.yml >./.web.yml

scp ./setup.sh \
    ./node_exporter.service \
    ./.web.yml \
    root@"$HOST":/tmp/node_exporter

rm -rf ./.web.yml

ssh root@"$HOST" 'mv /tmp/node_exporter/.web.yml /tmp/node_exporter/web.yml'

ssh root@"$HOST" 'cd /tmp/node_exporter && chmod +x ./setup.sh && ./setup.sh '$HOST

unalias ssh
unalias scp

echo "all done..."
