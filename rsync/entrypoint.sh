#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -e

SSH_PATH="$HOME/.ssh"
mkdir "$SSH_PATH"

ssh-keyscan -H $SERVER_NAME > "$SSH_PATH/known_hosts"
chmod 600 "$SSH_PATH/known_hosts"

echo "$DEPLOY_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"

rsync -az --delete --progress -e "ssh -p22 -i $SSH_PATH/deploy_key" $LOCAL_DIR $USERNAME@$SERVER_NAME:$REMOTE_DIR
