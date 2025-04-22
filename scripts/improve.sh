#!/usr/bin/env bash
set -euo pipefail

# Ubicaciones
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODEL="$PROJECT_ROOT/llamafile/models/ggml-model-q4_0.bin"
CLI="$PROJECT_ROOT/llamafile/llama.cpp/build/bin/llama-cli"

# Prompt base
read -r -d '' PROMPT << 'EOP'
You are a writing assistant. Improve the style, grammar, and clarity of the following text:
EOP

# Para cada línea de stdin, genera
while IFS= read -r chunk; do
  echo -e "\n=== Original ===\n$chunk\n"
  # construye el prompt completo
  FULL_PROMPT="$(printf "%s\n\n%s" "$PROMPT" "$chunk")"
  # llama al CLI
  echo "$FULL_PROMPT" | \
    "$CLI" \
      -m "$MODEL" \
      -p - \
      -n 128 \
      -t 4 \
      --temp 0.7 \
      --repeat_penalty 1.1
done
