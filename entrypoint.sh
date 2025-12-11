#!/bin/bash
set -e

echo "[entry] Starting custom GPU Minecraft server..."

#############################################
# 1. Basic Directories
#############################################
mkdir -p /data/mods /data/config
chmod -R 1000:1000 /data

#############################################
# 2. Type / Version handling
#############################################
MC_TYPE="${TYPE:-VANILLA}"
MC_VERSION="${VERSION:-LATEST}"

echo "[entry] Server type = $MC_TYPE"
echo "[entry] Server version = $MC_VERSION"

#############################################
# 3. Download server jars depending on TYPE
#############################################
download_fabric() {
    echo "[entry] Downloading Fabric installer..."

    curl -sSL -o fabric-installer.jar \
        "https://meta.fabricmc.net/v2/versions/installer/0.11.2/installer.jar"

    echo "[entry] Installing Fabric server..."
    java -jar fabric-installer.jar server -downloadMinecraft \
        -mcversion "$MC_VERSION" -loader 0.18.2 -noprofile

    SERVER_JAR="fabric-server-launch.jar"
}

download_vanilla() {
    echo "[entry] Downloading Vanilla server..."
    META_URL="https://launchermeta.mojang.com/mc/game/version_manifest.json"

    DL_URL=$(curl -sSL "$META_URL" | jq -r \
        ".versions[] | select(.id==\"$MC_VERSION\") | .url")

    SERVER_JAR_URL=$(curl -sSL "$DL_URL" | jq -r '.downloads.server.url')

    curl -sSL -o server.jar "$SERVER_JAR_URL"
    SERVER_JAR="server.jar"
}

case "$MC_TYPE" in
    FABRIC)
        download_fabric
        ;;
    VANILLA)
        download_vanilla
        ;;
    *)
        echo "[entry] Unknown TYPE=$MC_TYPE"
        exit 1
        ;;
esac

#############################################
# 4. JVM flags handling (itzg互換)
#############################################
JAVA_FLAGS=""

# memory
JAVA_FLAGS="$JAVA_FLAGS -Xms${INIT_MEMORY} -Xmx${MAX_MEMORY}"

# Aikar flags
if [[ "$USE_AIKAR_FLAGS" == "true" ]]; then
    JAVA_FLAGS="$JAVA_FLAGS -XX:+UseG1GC -XX:+ParallelRefProcEnabled \
      -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions"
fi

# meowice flags
if [[ "$USE_MEOWICE_FLAGS" == "true" ]]; then
    JAVA_FLAGS="$JAVA_FLAGS -XX:+UseZGC -XX:+ZUncommit -XX:MaxGCPauseMillis=40"
fi

# extra JVM opts
JAVA_FLAGS="$JAVA_FLAGS $JVM_OPTS $JVM_DD_OPTS $JVM_XX_OPTS"

#############################################
# 5. server.properties generation
#############################################
echo "[entry] Writing server.properties..."

cat >/data/server.properties <<EOF
motd=${MOTD}
difficulty=${DIFFICULTY}
max-players=${MAX_PLAYERS}
enable-rcon=${ENABLE_RCON}
rcon.password=${RCON_PASSWORD}
rcon.port=${RCON_PORT}
enable-whitelist=${ENABLE_WHITELIST}
EOF

#############################################
# 6. Whitelist
#############################################
if [[ "$ENABLE_WHITELIST" == "true" && "$WHITELIST" != "" ]]; then
    echo "[entry] Applying whitelist..."
    echo "$WHITELIST" | tr ',' '\n' | jq -R '{"name": .}' > /data/whitelist.json
fi

#############################################
# 7. GPU (OpenCL) runtime fixes
#############################################
echo "[entry] GPU(OpenCL) path: $LD_LIBRARY_PATH"
echo "[entry] Checking OpenCL ICD..."
ls -l /etc/OpenCL/vendors || true

#############################################
# 8. Run server
#############################################
echo "[entry] Running server with:"
echo "java $JAVA_FLAGS -jar $SERVER_JAR $EXTRA_ARGS"

exec java $JAVA_FLAGS -jar "$SERVER_JAR" $EXTRA_ARGS
