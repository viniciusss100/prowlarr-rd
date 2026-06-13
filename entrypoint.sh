#!/bin/sh
set -e

# Diretório de dados REAL usado pelo Prowlarr
CONFIG_DIR="/data"
export XDG_CONFIG_HOME="$CONFIG_DIR"
export HOME="$CONFIG_DIR"

echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

# Diretórios de indexadores
CUSTOM_DEF_DIR="$CONFIG_DIR/Definitions"
TARGET_DEF_DIR="$CONFIG_DIR/Definitions/Indexers"

echo "Verificando indexadores customizados em $CUSTOM_DEF_DIR"

# Criar diretório onde o Prowlarr realmente lê
mkdir -p "$TARGET_DEF_DIR"

echo "Conteúdo encontrado:"
ls -l "$CUSTOM_DEF_DIR" || echo "(pasta vazia)"

# Copiar .yml para o diretório correto
if ls "$CUSTOM_DEF_DIR"/*.yml >/dev/null 2>&1; then
    echo "Copiando arquivos .yml para $TARGET_DEF_DIR"
    cp -v "$CUSTOM_DEF_DIR"/*.yml "$TARGET_DEF_DIR"
else
    echo "Nenhum arquivo .yml encontrado."
fi

# Persistência do config.xml
if [ -f "$CONFIG_DIR/config.xml" ]; then
    echo "Usando config.xml persistente."
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml
else
    echo "Nenhum config.xml encontrado. O Prowlarr criará um novo."
fi

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
