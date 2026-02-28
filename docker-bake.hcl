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

variable "CIVITAI_ACCESS_TOKEN" {
  default = ""
}

# ─── Build groups ───
group "default" {
  targets = ["base"]
}

target "base" {
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "base"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base"]
}

target "flux2-klein" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux2-klein"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux2-klein"]
  inherits = ["base"]
}

target "Wan_i2v_default" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "Wan_i2v_default"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-wan-i2v-default"]
  inherits = ["base"]
}

target "Wan_i2v_dasiwa" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "Wan_i2v_dasiwa"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
    CIVITAI_ACCESS_TOKEN = "${CIVITAI_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-wan-i2v-dasiwa"]
  inherits = ["base"]
}

