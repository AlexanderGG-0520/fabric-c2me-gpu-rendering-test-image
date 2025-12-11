# 例: ghcr.io/alexandergg-0520/fabric-c2me-gpu-server:latest
FROM bitnami/minideb:bookworm

# 環境
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 必要パッケージ
# - openjdk-21-jre-headless : Minecraftサーバー用
# - curl, wget, ca-certificates : ダウンロード系
# - tzdata : タイムゾーン
# - mc : MinIO client（名前被り防止のため /usr/local/bin/mc にリンク）
# - ocl-icd-libopencl1 : 汎用 OpenCL ローダ（GPUベンダーのICDはホストからmountする想定）
RUN install_packages \
      openjdk-21-jre-headless \
      curl wget ca-certificates \
      tzdata \
      jq \
      libssl3 \
      ocl-icd-libopencl1 \
      bash \
      tini \
      procps && \
    curl -fsSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc && \
    mkdir -p /opt/minecraft /data /mods /config && \
    useradd -r -u 1000 -g users mcserver && \
    chown -R mcserver:users /opt/minecraft /data /mods /config

# 作業ディレクトリ
WORKDIR /opt/minecraft

# エントリポイントスクリプトをコピー
COPY entrypoint.sh /opt/minecraft/entrypoint.sh
RUN chmod +x /opt/minecraft/entrypoint.sh && \
    chown mcserver:users /opt/minecraft/entrypoint.sh

# （任意）server.jar や、mc-image-helper 相当のツールをここに追加してもOK
# COPY server.jar /opt/minecraft/server.jar

# データ用ボリューム
VOLUME ["/data"]

# デフォルトポート
EXPOSE 25565

USER mcserver

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/minecraft/entrypoint.sh"]
