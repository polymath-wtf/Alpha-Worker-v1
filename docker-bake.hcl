variable "DOCKERHUB_REPO" {
  default = "runpod"
}

variable "DOCKERHUB_IMG" {
  default = "worker-comfyui"
}

variable "RELEASE_VERSION" {
  default = "latest"
}

variable "COMFYUI_VERSION" {
  default = "latest"
}

# ─── CUDA 13.0 defaults for RTX 5090 (Blackwell) ───
# NVFP4 quantization requires SM 10.0 + CUDA Runtime >=13.0
# comfy-kitchen[cublas] CUDA backend requires PyTorch cu130
variable "BASE_IMAGE" {
  default = "nvidia/cuda:13.0.2-cudnn-runtime-ubuntu24.04"
}

variable "PYTORCH_INDEX_URL" {
  default = "https://download.pytorch.org/whl/cu130"
}

variable "HUGGINGFACE_ACCESS_TOKEN" {
  default = ""
}

# ─── Build groups ───
group "default" {
  targets = ["base", "sdxl", "sd3", "flux1-schnell", "flux1-dev", "flux1-dev-fp8", "base-cuda12-8-1"]
}

target "base" {
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "base"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base"]
}

target "sdxl" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "sdxl"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-sdxl"]
  inherits = ["base"]
}

target "sd3" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "sd3"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-sd3"]
  inherits = ["base"]
}

target "flux1-schnell" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-schnell"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-schnell"]
  inherits = ["base"]
}

target "flux1-dev" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-dev"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-dev"]
  inherits = ["base"]
}

target "flux1-dev-fp8" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-dev-fp8"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-dev-fp8"]
  inherits = ["base"]
}

target "base-cuda12-8-1" {
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = ""
    ENABLE_PYTORCH_UPGRADE = "true"
    PYTORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128"
    MODEL_TYPE = "base"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base-cuda12.8.1"]
}

