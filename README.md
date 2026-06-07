# 🧠 Kaggle AI Notebooks

A curated collection of Jupyter notebooks for running AI models on Kaggle (free GPU access). Covers image generation, video generation, LLM inference, fine-tuning, and model conversion.

> ⚠️ **Security Note:** All notebooks use `Your_Ngrok_Token_Here` as a placeholder. Replace with your own token from [ngrok.com](https://ngrok.com) before running. Store sensitive tokens using [Kaggle Secrets](https://www.kaggle.com/discussions/product-feedback/114053) — never hardcode them.

---

## 📂 Notebooks

### 🎨 Image Generation

| Notebook | Description | GPU Required |
|---|---|---|
| `comfyui.ipynb` | Run ComfyUI on Kaggle with a full node-based workflow interface | T4 x2 |
| `comfyui-flux2fleinedit.ipynb` | ComfyUI setup with FLUX2 fine-tuned image editing workflows | T4 x2 |
| `kaggle-stable-diffusion-inpainting3-5.ipynb` | Stable Diffusion 3.5 inpainting via diffusers + ngrok API tunnel | T4 |
| `mastering-image-generation-with-stable-diffusion.ipynb` | Complete SD workflow: txt2img, img2img, inpainting, ControlNet | T4 x2 |
| `ggufimage.ipynb` | Image generation using GGUF-quantized models via llama-cpp | T4 |
| `unsloth-z-image-turbo-gguf.ipynb` | Turbo image gen with Unsloth + GGUF quantization | T4 |

### 🎬 Video Generation

| Notebook | Description | GPU Required |
|---|---|---|
| `ltx-2-3-a2v-q4-kaggle (1).ipynb` | LTX Video 2.3 audio-to-video generation (Q4 quantized) | T4 x2 |
| `ltx2-3-video.ipynb` | Lightweight LTX 2.3 video generation setup | T4 |

### 🤖 LLM Inference & Chat

| Notebook | Description | GPU Required |
|---|---|---|
| `gemma4-12b.ipynb` | Gemma 4 12B inference with FastAPI + ngrok tunnel | T4 x2 |
| `qwen2-5working.ipynb` | Qwen 2.5 LLM basic inference and chat | T4 |
| `qwen3api.ipynb` | Qwen 3 OpenAI-compatible API server on Kaggle | T4 x2 |
| `qwen2-5vl-streamapp.ipynb` | Qwen 2.5-VL vision model with Streamlit UI for GeoTag OCR | T4 |
| `hauhaucs-qwen3-5-35b-a3b-uncensored-hauhaucs-aggre.ipynb` | Qwen 3.5 35B GGUF inference + llama-cpp server + ngrok | T4 x2 |
| `omni-voice-model-my.ipynb` | Omni voice/multimodal model inference | T4 |

### 🏋️ Fine-Tuning & Training

| Notebook | Description | GPU Required |
|---|---|---|
| `uncenceror-tranning.ipynb` | LLM fine-tuning pipeline with Unsloth | T4 x2 |
| `unsloth-studio.ipynb` | Unsloth Studio fine-tuning interface + ngrok tunnel | T4 x2 |
| `sdmodelworking2026.ipynb` | Full Stable Diffusion training workflow (2026 setup) | T4 x2 |

### 🔧 Model Utilities

| Notebook | Description | GPU Required |
|---|---|---|
| `convert-training-to-gguf.ipynb` | Convert fine-tuned models to GGUF format for deployment | T4 |
| `downlaod-models.ipynb` | Bulk download HuggingFace models to Kaggle disk | None |

---

## 🚀 Quick Start

1. **Fork** this repo or copy a notebook to your Kaggle account
2. Enable **GPU accelerator** (T4 x2 recommended for most notebooks)
3. Enable **Internet** in notebook settings
4. Set your secrets in **Add-ons → Secrets**:
   - `HF_TOKEN` — HuggingFace read token
   - `NGROK_AUTH_TOKEN` — ngrok authentication token
5. Replace any `Your_Ngrok_Token_Here` placeholders with your actual token
6. Run cells top to bottom

---

## 🔐 Secret Management Best Practice

Use Kaggle's built-in secrets manager instead of hardcoding tokens:

```python
from kaggle_secrets import UserSecretsClient
user_secrets = UserSecretsClient()
hf_token = user_secrets.get_secret("HF_TOKEN")
ngrok_token = user_secrets.get_secret("NGROK_AUTH_TOKEN")
```

Never commit real API keys or tokens to version control.

---

## 📦 Dependencies

Most notebooks auto-install required packages. Common dependencies:

- `transformers`, `accelerate`, `bitsandbytes` — HuggingFace model loading
- `diffusers` — Stable Diffusion / image generation
- `llama-cpp-python` — GGUF model inference
- `pyngrok` — Expose local servers via ngrok tunnel
- `unsloth` — Fast LLM fine-tuning
- `streamlit` — Web UI for model demos
- `fastapi`, `uvicorn` — OpenAI-compatible API server

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
