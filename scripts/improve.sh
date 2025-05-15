#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

MODEL="$PROJECT_ROOT/llamafile/models/ggml-model-q4_0.bin"
CLI="$PROJECT_ROOT/llamafile/llama.cpp/bin/llama-cli"

read -r -d '' PROMPT << 'EOF'
You are a writing assistant. Improve the style, grammar, and clarity of the following text. Return only the improved text, without any explanations or additional comments. Do not include any introductory phrases like 'Improved text:' or similar.
EOF

while IFS= read -r chunk; do
  echo -e "\n=== Original ===\n$chunk\n"
  echo -e "$PROMPT\n$chunk" | \
    "$CLI" \
      -m "$MODEL" \
      --temp 0.7 \
      --repeat_penalty 1.1 \
      --max_new_tokens 128
done
