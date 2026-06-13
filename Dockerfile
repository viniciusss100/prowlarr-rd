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
    apt-get install -y libicu-dev libssl-dev tinyproxy && \
    apt-get clean

WORKDIR /app

COPY --from=build /app/Prowlarr /app/Prowlarr/

RUN mkdir -p /config/Definitions
COPY config/Definitions/. /config/Definitions/

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV DOTNET_SYSTEM_NET_DISABLEIPV6=1

EXPOSE 9696
ENTRYPOINT ["/entrypoint.sh"]
CMD []
