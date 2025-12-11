#
# Minecraft GPU-Ready Server Image (Fabric/C2ME/OpenCL)
# Base: Debian Bookworm Slim
# Author: alexandergg-0520
#

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# ========= System Packages =========
RUN apt-get update && apt-get install -y \
      openjdk-21-jre-headless \
      curl wget ca-certificates \
      tzdata \
      jq \
      bash \
      tini \
      procps \
      rsync \
      ocl-icd-libopencl1 \
      pciutils \
    && rm -rf /var/lib/apt/lists/*

# ========= MinIO CLI =========
RUN curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc \
      -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc

# ========= Directories =========
RUN mkdir -p /opt/minecraft /data /mods /config /opencl \
    && useradd -r -u 1000 -g users mcserver \
    && chown -R mcserver:users /opt/minecraft /data /mods /config /opencl

WORKDIR /opt/minecraft

USER mcserver

# ========= Environment Variables (itzg compatibility style) =========
ENV EULA=FALSE \
    VERSION="latest" \
    TYPE="VANILLA" \
    SERVER_PORT=25565 \
    MEMORY=4G \
    MAX_PLAYERS=20 \
    MOTD="Minecraft Server" \
    ENABLE_COMMAND_BLOCK=FALSE \
    ALLOW_FLIGHT=FALSE \
    JVM_OPTS="" \
    TZ=Asia/Tokyo \
    # GPU Settings
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    LD_LIBRARY_PATH="/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opencl"

# ========= Run Script =========
COPY run.sh /opt/minecraft/run.sh
RUN chmod +x /opt/minecraft/run.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/opt/minecraft/run.sh"]
