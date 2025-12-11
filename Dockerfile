FROM eclipse-temurin:21-jre-jammy

# --- Basic dependencies ---
RUN apt-get update && apt-get install -y \
    curl unzip jq ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# --- OpenCL ICD loader + vendor filesを使うための準備 ---
RUN apt-get update && apt-get install -y \
    ocl-icd-libopencl1 \
    && rm -rf /var/lib/apt/lists/*

# NVIDIA コンテナランタイムを使う前提
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/targets/x86_64-linux/lib:${LD_LIBRARY_PATH}"

# --- Directories ---
RUN mkdir -p /data /mods /config /opt/mc
WORKDIR /opt/mc

# --- Entry script ---
COPY entrypoint.sh /opt/mc/entrypoint.sh
RUN chmod +x /opt/mc/entrypoint.sh

# --- Default ENV (itzg互換＋拡張) ---
ENV TYPE="VANILLA" \
    VERSION="LATEST" \
    MEMORY="4G" \
    INIT_MEMORY="1G" \
    MAX_MEMORY="4G" \
    USE_AIKAR_FLAGS="false" \
    USE_MEOWICE_FLAGS="false" \
    USE_MEOWICE_GRAALVM_FLAGS="false" \
    JVM_OPTS="" \
    JVM_DD_OPTS="" \
    JVM_XX_OPTS="" \
    EXTRA_ARGS="" \
    MOTD="A Minecraft Server Running with GPU OpenCL" \
    DIFFICULTY="normal" \
    MAX_PLAYERS="20" \
    ENABLE_WHITELIST="false" \
    WHITELIST="" \
    ENABLE_RCON="false" \
    RCON_PASSWORD="" \
    RCON_PORT="25575"

# Expose ports
EXPOSE 25565 25575

VOLUME ["/data"]

ENTRYPOINT ["/opt/mc/entrypoint.sh"]
