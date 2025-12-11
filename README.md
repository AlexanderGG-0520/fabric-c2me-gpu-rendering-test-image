# 🚀 GPU-Accelerated Fabric Minecraft Server  

## Powered by C2ME OpenCL • Kubernetes • ArgoCD • MinIO

This project provides a fully containerized **Fabric Minecraft Server** with **GPU-accelerated OpenCL chunk computation (C2ME)**, automatic **mod/config synchronization via MinIO**, and complete **Kubernetes + ArgoCD compatibility**.

It is designed for advanced Minecraft server operators who want reliable GitOps workflows, reproducible environments, and optional hardware acceleration.

---

## ✨ Features

### 🔥 GPU-Accelerated C2ME (OpenCL)

- Enables OpenCL acceleration for chunk processing  
- Automatically loads system OpenCL libraries  
- Compatible with NVIDIA GPUs via `nvidia-device-plugin`  
- No modification needed inside the container image  

---

### ☁️ MinIO-Based Mod & Config Sync

At startup, the container automatically synchronizes:

```md
minio/<bucket>/mods/
minio/<bucket>/config/
```

Features:

- Ensures modpack consistency  
- Removes outdated files  
- Enables remote modpack management  

---

## ⚙️ Environment Variable Configuration  

Inspired by **itzg/docker-minecraft-server**, this image supports flexible tuning:

| Variable | Description |
|---------|-------------|
| `TYPE` | VANILLA / FABRIC (default: VANILLA) |
| `VERSION` | Minecraft version, e.g. `1.21.10` |
| `INIT_MEMORY` | Initial JVM memory |
| `MAX_MEMORY` | Maximum JVM memory |
| `USE_AIKAR_FLAGS` | Enables Aikar flags |
| `MOTD` | Server MOTD |
| `DIFFICULTY` | easy / normal / hard |
| `ONLINE_MODE` | true / false |

Defaults follow **vanilla behavior** for safety.

---

## 🛠 Kubernetes & ArgoCD Ready

This repository includes manifests under `examples/`:

```md
examples/
 ├── fabric-gpu-opencl.yaml
 └── fabric-gpu-opencl-minio-sync.yaml
```

Supports:

- ArgoCD automated sync  
- GitOps workflow  
- Full self-healing  

---

## 📁 Repository Structure

```md
.
├── Dockerfile
├── entrypoint.sh
├── examples/
│   ├── fabric-gpu-opencl.yaml
│   └── fabric-gpu-opencl-minio-sync.yaml
└── README.md
```

---

## 🚀 Quick Start (Kubernetes + ArgoCD)

### 1. Create the namespace

```sh
kubectl create namespace mc-server
```

### 2. Apply with ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: fabric-gpu
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOURNAME/minecraft-fabric-gpu
    path: examples
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: mc-server
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 🖥 GPU Requirements

You must ensure:

- NVIDIA GPU node  
- Installed `nvidia-device-plugin`  
- OpenCL libraries exist on host:  
  - `libOpenCL.so.1`  
  - `libnvidia-opencl.so.1`  

---

## ☁️ Optional MinIO Integration

MinIO bucket structure:

```md
minecraft/mods/
minecraft/config/
```

Mods → `mods/`  
Configs → `config/`  

All files sync automatically at container startup.

---

## 🔧 Environment Variables (Expanded)

Category | Variables  

--- | ---  
Server | `TYPE`, `VERSION`  
Memory | `INIT_MEMORY`, `MAX_MEMORY`  
JVM | `USE_AIKAR_FLAGS`, `EXTRA_JVM_OPTS`  
Gameplay | `MOTD`, `DIFFICULTY`, `ONLINE_MODE`  
MinIO | `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_BUCKET`

More variables will be added as the project evolves.

---

## 🧩 Roadmap

- Reach parity with itzg/docker-minecraft-server ENV variables  
- World backups (MinIO)  
- Crash rollback  
- Prometheus metrics  
- Optional Purpur/Paper GPU builds  

---

## 🤝 Contributing

PRs and issues are welcome!

---

## 📝 License

MIT License
