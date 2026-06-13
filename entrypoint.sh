#!/bin/sh
set -e

CONFIG_DIR="/data"
export XDG_CONFIG_HOME="$CONFIG_DIR"
export HOME="$CONFIG_DIR"

echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

CUSTOM_DEF_DIR="$CONFIG_DIR/Definitions"
TARGET_DEF_DIR="$CONFIG_DIR/Definitions/Indexers"

mkdir -p "$TARGET_DEF_DIR"

echo "Conteúdo encontrado em $CUSTOM_DEF_DIR:"
ls -l "$CUSTOM_DEF_DIR" || echo "(pasta vazia)"

if ls "$CUSTOM_DEF_DIR/Indexers"/*.yml >/dev/null 2>&1; then
    cp -v "$CUSTOM_DEF_DIR/Indexers"/*.yml "$TARGET_DEF_DIR/" || true
else
    echo "Nenhum arquivo .yml encontrado."
fi

if [ -f "$CONFIG_DIR/config.xml" ]; then
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml
fi

echo "Iniciando tinyproxy..."
service tinyproxy start

export http_proxy="http://127.0.0.1:8888"
export https_proxy="http://127.0.0.1:8888"
export DOTNET_SYSTEM_NET_DISABLEIPV6=1

exec /app/Prowlarr/Prowlarr \
  --nobrowser \
  --data="$CONFIG_DIR"
