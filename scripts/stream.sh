cat << 'EOF' > scripts/stream.sh
#!/usr/bin/env bash
set -xuo pipefail

# Calcula la carpeta donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Dispositivo de audio: plughw hace el remuestreo automático
MIC="plughw:1,0"

# Rutas absolutas al modelo y al ejecutable de whisper.cpp
MODEL="$PROJECT_ROOT/models/whisper.cpp/models/ggml-base.bin"
CLI="$PROJECT_ROOT/models/whisper.cpp/build/bin/whisper-cli"

# Comprueba que existen
[ -x "$CLI" ]   || { echo "ERROR: no existe $CLI"; exit 1; }
[ -f "$MODEL" ] || { echo "ERROR: no existe $MODEL"; exit 1; }

# Captura WAV del mic y pipe al recognizer en español, sin timestamps
arecord -D "$MIC" -f cd -c1 -t wav | \
  "$CLI" -m "$MODEL" -l es -f - --no-timestamps
EOF

chmod +x scripts/stream.sh