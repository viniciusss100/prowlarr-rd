#!/bin/sh
set -e

: "${XDG_CONFIG_HOME:=/data}"
CONFIG_DIR="$XDG_CONFIG_HOME"
export HOME="$XDG_CONFIG_HOME"

echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

CUSTOM_DEF_DIR="$CONFIG_DIR/Definitions"
TARGET_DEF_DIR="$CONFIG_DIR/Definitions/Indexers"

mkdir -p "$TARGET_DEF_DIR"

echo "Conteúdo encontrado em $CUSTOM_DEF_DIR:"
ls -l "$CUSTOM_DEF_DIR" || echo "(pasta vazia)"

if ls "$CUSTOM_DEF_DIR"/*.yml >/dev/null 2>&1; then
    echo "Copiando arquivos .yml para $TARGET_DEF_DIR"
    cp -v "$CUSTOM_DEF_DIR"/*.yml "$TARGET_DEF_DIR"
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
