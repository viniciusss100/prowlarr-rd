#!/bin/sh
set -e

CONFIG_DIR="/data"
export XDG_CONFIG_HOME="$CONFIG_DIR"
export HOME="$CONFIG_DIR"

echo "=== Inicializando Prowlarr ==="
echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

# Copiar indexadores customizados
INDEXERS_SRC="$CONFIG_DIR/Definitions/Indexers"
INDEXERS_DST="$CONFIG_DIR/Definitions/Indexers"

mkdir -p "$INDEXERS_DST"

if [ -d "$INDEXERS_SRC" ] && [ ! -z "$(ls -A $INDEXERS_SRC 2>/dev/null)" ]; then
    echo "[✓] Encontrados indexadores customizados"
    ls -la "$INDEXERS_SRC"/*.yml 2>/dev/null | while read -r file; do
        echo "  → $(basename $file)"
    done
else
    echo "[!] Nenhum indexador customizado encontrado"
fi

# Copiar config.xml se existir (criado via UI do Prowlarr)
if [ -f "$CONFIG_DIR/config.xml" ]; then
    echo "[✓] Copiando config.xml existente..."
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml
else
    echo "[!] Nenhum config.xml encontrado (será criado no primeiro acesso)"
fi

# Copiar outros arquivos de configuração importantes
for file in "$CONFIG_DIR"/*.json "$CONFIG_DIR"/*.db "$CONFIG_DIR"/*.sqlite "$CONFIG_DIR"/*.sqlite3 2>/dev/null; do
    if [ -f "$file" ]; then
        echo "[✓] Copiando $(basename $file)..."
        cp -f "$file" /app/Prowlarr/ 2>/dev/null || true
    fi
done

echo ""
echo "=== Iniciando tinyproxy ==="
service tinyproxy start

export http_proxy="http://127.0.0.1:8888"
export https_proxy="http://127.0.0.1:8888"
export DOTNET_SYSTEM_NET_DISABLEIPV6=1

echo "=== Iniciando Prowlarr ==="
exec /app/Prowlarr/Prowlarr \
  --nobrowser \
  --data="$CONFIG_DIR"
