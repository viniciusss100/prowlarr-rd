# --- Build stage ---
FROM debian:stable-slim AS build

RUN apt-get update && \
    apt-get install -y curl jq tar && \
    apt-get clean

RUN LATEST_URL=$(curl -s "https://api.github.com/repos/Prowlarr/Prowlarr/releases/latest" \
    | jq -r '.assets[] | select(.name | contains("linux-core-x64")) | .browser_download_url') && \
    echo "Baixando Prowlarr de: $LATEST_URL" && \
    curl -L -o /tmp/prowlarr.tar.gz "$LATEST_URL"

RUN mkdir -p /app/Prowlarr
RUN tar xf /tmp/prowlarr.tar.gz -C /app/Prowlarr --strip-components=1

# --- Final image ---
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y libicu-dev libssl-dev && \
    apt-get clean

WORKDIR /app

COPY --from=build /app/Prowlarr /app/Prowlarr/

# AQUI ESTÁ A CORREÇÃO
COPY config/Definitions/ /config/Definitions/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9696
ENTRYPOINT ["/entrypoint.sh"]
CMD []
