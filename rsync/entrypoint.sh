#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -e

PORT="${PORT-22}"

SSH_PATH="$HOME/.ssh"
mkdir "$SSH_PATH"

echo "$DEPLOY_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"

rsync -az --delete --progress -e "ssh -p $PORT -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no" $LOCAL_DIR $USERNAME@$SERVER_NAME:$REMOTE_DIR
