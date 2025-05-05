#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script to initialize submodules, build binaries, and download default models for dictado-llm

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Initialize and update submodules
echo "[1/5] Initializing git submodules..."
git submodule update --init --recursive

# 2. Build whisper.cpp CLI
echo "[2/5] Building whisper.cpp..."
(
  cd "$ROOT/models/whisper.cpp"
  mkdir -p build && cd build
  cmake .. && make -j"$(nproc)"
)

# 3. Build llama.cpp CLI
echo "[3/5] Building llama.cpp..."
(
  cd "$ROOT/llamafile/llama.cpp"
  mkdir -p build && cd build
  cmake .. && make -j"$(nproc)"
)

# 4. Download default Whisper model (base)
WHISPER_MODEL_PATH="$ROOT/models/whisper.cpp/models/ggml-base.bin"
echo "[4/5] Ensuring Whisper model exists at $WHISPER_MODEL_PATH..."
if [ ! -f "$WHISPER_MODEL_PATH" ]; then
  echo "  -> Downloading base model for whisper.cpp"
  bash "$ROOT/models/whisper.cpp/models/download-ggml-model.sh" base "$ROOT/models/whisper.cpp/models"
else
  echo "  -> Whisper base model already present."
fi

# 5. Prepare llama quantized model
LLAMA_MODEL_DIR="$ROOT/llamafile/models"
LLAMA_MODEL_PATH="$LLAMA_MODEL_DIR/ggml-model-q4_0.bin"
echo "[5/5] Checking for Llama quantized model at $LLAMA_MODEL_PATH..."
if [ ! -f "$LLAMA_MODEL_PATH" ]; then
  mkdir -p "$LLAMA_MODEL_DIR"
  if [ -n "${HF_LLAMA_MODEL:-}" ]; then
    echo "  -> Converting HuggingFace checkpoint at $HF_LLAMA_MODEL to ggml q4_0"
    python3 "$ROOT/llamafile/llama.cpp/convert_hf_to_gguf.py" \
      --model "$HF_LLAMA_MODEL" \
      "$LLAMA_MODEL_PATH" \
      --quantize q4_0
  else
    echo "  -> WARNING: Llama model not found."
    echo "     Set HF_LLAMA_MODEL to a HuggingFace checkpoint or drop a quantized ggml-model-q4_0.bin into $LLAMA_MODEL_DIR"
  fi
else
  echo "  -> Llama quantized model already present."
fi

echo "Bootstrap complete. You can now run scripts/stream.sh and scripts/improve.sh"