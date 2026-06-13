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

# Copia indexadores customizados para o diretório oficial
if [ -d "$CUSTOM_DEF_DIR" ]; then
    echo "Copiando indexadores customizados para $PROWLARR_DEF_DIR"
    cp -f "$CUSTOM_DEF_DIR"/*.yml "$PROWLARR_DEF_DIR" 2>/dev/null || true
else
    echo "Nenhum diretório de indexadores custom encontrados."
fi

# Persistência do config.xml
# Se o usuário já tiver um config.xml em /config, ele deve sobrescrever o padrão
if [ -f "$CONFIG_DIR/config.xml" ]; then
    echo "Usando config.xml persistente."
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml
else
    # Se ainda não existir, cria um config.xml padrão ao iniciar
    echo "Nenhum config.xml encontrado. O Prowlarr criará um novo."
fi

# API key opcional via variável de ambiente
if [ -n "$PROWLARR_API_KEY" ]; then
  echo "API key definida via PROWLARR_API_KEY."
  export PROWLARR__APIKEY="$PROWLARR_API_KEY"
else
  echo "Nenhuma PROWLARR_API_KEY definida. Prowlarr gerará uma automaticamente."
fi

echo "Iniciando Prowlarr..."
exec /app/Prowlarr/Prowlarr \
  --nobrowser \
  --data="$CONFIG_DIR"
