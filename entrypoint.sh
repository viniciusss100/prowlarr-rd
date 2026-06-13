#!/bin/sh
set -e

: "${XDG_CONFIG_HOME:=/config}"
CONFIG_DIR="$XDG_CONFIG_HOME"
export HOME="$XDG_CONFIG_HOME"

echo "HOME = $HOME"
echo "XDG_CONFIG_HOME = $XDG_CONFIG_HOME"
echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

# Diretórios
CUSTOM_DEF_DIR="$CONFIG_DIR/Definitions"
TARGET_DEF_DIR="/app/Prowlarr/Definitions/Indexers"

echo "Verificando indexadores customizados em $CUSTOM_DEF_DIR"

# Criar diretório real do Prowlarr
mkdir -p "$TARGET_DEF_DIR"

echo "Conteúdo encontrado em $CUSTOM_DEF_DIR:"
ls -l "$CUSTOM_DEF_DIR" || echo "(pasta vazia)"

# Copiar .yml
if ls "$CUSTOM_DEF_DIR"/*.yml >/dev/null 2>&1; then
    echo "Copiando arquivos .yml para $TARGET_DEF_DIR"
    cp -v "$CUSTOM_DEF_DIR"/*.yml "$TARGET_DEF_DIR"
else
    echo "Nenhum arquivo .yml encontrado em $CUSTOM_DEF_DIR"
fi

# Persistência do config.xml
if [ -f "$CONFIG_DIR/config.xml" ]; then
    echo "Usando config.xml persistente."
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml
else
    echo "Nenhum config.xml encontrado. O Prowlarr criará um novo."
fi

# Iniciar tinyproxy
echo "Iniciando tinyproxy..."
service tinyproxy start

# Forçar uso do proxy
export http_proxy="http://127.0.0.1:8888"
export https_proxy="http://127.0.0.1:8888"

# Forçar IPv4
export DOTNET_SYSTEM_NET_DISABLEIPV6=1

echo "Iniciando Prowlarr..."
exec /app/Prowlarr/Prowlarr \
  --nobrowser \
  --data="$CONFIG_DIR"
