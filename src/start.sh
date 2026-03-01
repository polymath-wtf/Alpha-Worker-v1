#!/usr/bin/env bash
# =============================================================================
# ComfyUI Worker — RTX 5090 (Blackwell) / CUDA 13.0 / NVFP4
# =============================================================================

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Ensure CUDA 13 libs are on the library path
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Ensure ComfyUI-Manager runs in offline network mode inside the container
comfy-manager-set-mode offline || echo "worker-comfyui - Could not set ComfyUI-Manager network_mode" >&2

echo "worker-comfyui: Starting ComfyUI"

# ── Diagnostics ──────────────────────────────────────────────────────────────
python --version
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'CUDA Version: {torch.version.cuda}')"

# GPU info
nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv

# comfy-kitchen backend check — should show cuda+triton enabled (not disabled)
python -c "\
import comfy_kitchen as ck; \
backends = ck.list_backends(); \
print(f'comfy-kitchen backends: {backends}'); \
" 2>&1 || echo "worker-comfyui - WARN: comfy-kitchen backend check failed"

# SageAttention3 check — ComfyUI imports sageattn3 directly, activates via KJNodes sage3
python -c "from sageattn3 import sageattn3_blackwell; print('SageAttention3 (NVFP4 Blackwell): check zbs')" 2>&1 \
    || echo "worker-comfyui - WARN: sageattn3 not available, ComfyUI will use SUKA BLYAT"

# ── ComfyUI Launch Args ─────────────────────────────────────────────────────
# Allow operators to tweak verbosity; default is DEBUG.
: "${COMFY_LOG_LEVEL:=DEBUG}"

# Common args for all launch modes:
#   --normalvram          — standard VRAM allocation (5090 has 32GB)
#   --reserve-vram 1      — reserve 1GB for OS/driver overhead
#   --disable-smart-memory — let ComfyUI handle memory without heuristics
#   --disable-metadata    — skip embedding metadata in output files
#   sageattn3 activated per-workflow via KJNodes attention_function="sage3" node

COMFY_ARGS="--disable-auto-launch --normalvram --disable-metadata --verbose ${COMFY_LOG_LEVEL} --log-stdout"

# Serve the API and don't shutdown the container
if [ "$SERVE_API_LOCALLY" == "true" ]; then
    python -u /comfyui/main.py ${COMFY_ARGS} --listen &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    python -u /comfyui/main.py ${COMFY_ARGS} &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py
fi