#!/usr/bin/env bash
# scripts/stream.sh

# Dispositivo de audio: plughw hace el remuestreo automático
MIC="plughw:1,0"

# Ruta al modelo y al ejecutable de whisper.cpp
MODEL="../models/whisper.cpp/models/ggml-base.bin"
CLI="../models/whisper.cpp/build/bin/whisper-cli"

# Captura WAV y lo pasa a whisper-cli forzando español y sin timestamps
arecord -D "$MIC" -f cd -c1 -t wav | \
  "$CLI" -m "$MODEL" -l es -f - --no-timestamps
