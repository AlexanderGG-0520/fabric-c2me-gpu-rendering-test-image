FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# ===== 必須パッケージ =====
RUN apt-get update && apt-get install -y \
      openjdk-21-jre-headless \
      curl wget ca-certificates \
      tzdata \
      jq \
      bash \
      tini \
      procps \
      rsync \
      libopencl1 \
      pciutils \
    && rm -rf /var/lib/apt/lists/*

# ===== MinIO CLI =====
RUN curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc \
      -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc

# ===== ディレクトリ作成 =====
RUN mkdir -p /opt/minecraft /data /mods /config \
    && groupadd -g 1000 mcserver \
    && useradd -r -u 1000 -g mcserver mcserver \
    && chown -R mcserver:mcserver /opt/minecraft /data /mods /config

WORKDIR /opt/minecraft

USER mcserver

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash"]
