#!/usr/bin/env bash
# Purpose: Make Node.js binaries available
# Usage: |
#   $ source ./install.sh
# Authors:
#   Author1: Paulo Jerônimo (paulojeronimo@gmail.com)
#

DOCKER_NODE_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")"; pwd`
DOCKER_NODE_VER=${DOCKER_NODE_VER:-12}

case "$OSTYPE" in
  darwin*) profile=~/.bash_profile;;
  linux-gnu) profile=~/.bashrc;;
esac

[ "$profile" ] || {
  echo "`dirname "$DOCKER_NODE_DIR"` can not be installed on \"$OSTYPE\""
  return 1
}

[ -f "$profile" ] || touch $profile

grep -q "^source \"$DOCKER_NODE_DIR/install.sh\"$" $profile || {
  echo "source \"$DOCKER_NODE_DIR/install.sh\"" >> $profile
}

unset profile

docker-node-version() {
  local nv="$DOCKER_NODE_DIR"/node-version
  case "$1" in
    -s|--set)
      if [ "$2" ]; then
        echo $2 > $nv
        echo "docker-node will now use node:$2 image!"
      elif [ -f $nv ]; then
        DOCKER_NODE_VER=`cat $nv`
      else
        echo $DOCKER_NODE_VER > $nv
      fi
      return 0
  esac
  cat $nv
}
docker-node-image() {
  echo -n "node:`docker-node-version`"
}
docker-node-run() {
  local dp
  [ "$1" = "bash" ] && dp="-it"
  dp="$dp --rm"
  dp="$dp -v "$PWD":/usr/src/app"
  dp="$dp -w /usr/src/app"
  docker run $dp `docker-node-image` "$@"
}
node() { docker-node-run "$@"; }
npm() { docker-node-run npm "$@"; }
npx() { docker-node-run npx "$@"; }
yarn() { docker-node-run yarn "$@"; }

docker-node-version -s
