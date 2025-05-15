#!/usr/bin/env bash
set -euo pipefail

# Calcula directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Dispositivo de audio (usa plughw para remuestrear)
MIC="plughw:1,0"

# Rutas a modelo y CLI
MODEL="$PROJECT_ROOT/models/whisper.cpp/models/ggml-base.bin"
CLI="/workspace/dictado-llm/models/whisper.cpp/build/bin/whisper-cli"

# Duración de cada trozo en segundos
CHUNK_DUR=3

# Directorio temporal para los chunks
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "=== Starting live chunked dictation (chunk size = ${CHUNK_DUR}s) ==="

while true; do
  CHUNK="$TMPDIR/chunk.wav"
  echo "--- Recording $CHUNK_DUR s to $CHUNK ---"
  arecord -D "$MIC" -f cd -c1 -t wav -d $CHUNK_DUR "$CHUNK"

  echo "--- Transcribing chunk ---"
  "$CLI" -m "$MODEL" -l es -f "$CHUNK" --no-timestamps

  echo
done
