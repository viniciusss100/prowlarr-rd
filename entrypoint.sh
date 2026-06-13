#!/bin/sh
set -e

# Diretório de configuração persistente
: "${XDG_CONFIG_HOME:=/config}"
CONFIG_DIR="$XDG_CONFIG_HOME"
export HOME="$XDG_CONFIG_HOME"

echo "HOME = $HOME"
echo "XDG_CONFIG_HOME = $XDG_CONFIG_HOME"
echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

# Diretório oficial de definições do Prowlarr
PROWLARR_DEF_DIR="/app/Prowlarr/Definitions"

# Diretório onde o usuário coloca indexadores customizados
CUSTOM_DEF_DIR="$CONFIG_DIR/Definitions"

echo "Verificando indexadores customizados em $CUSTOM_DEF_DIR"

if [ -d "$CUSTOM_DEF_DIR" ]; then
    echo "Copiando indexadores customizados para $PROWLARR_DEF_DIR"
    cp -f "$CUSTOM_DEF_DIR"/*.yml "$PROWLARR_DEF_DIR" 2>/dev/null || true
else
    echo "Nenhum diretório de indexadores custom encontrados."
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
