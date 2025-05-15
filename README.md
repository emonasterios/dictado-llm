# dictado-llm

## Overview

dictado-llm is a voice dictation system that allows users to dictate text into any text field in a Linux system. It uses Whisper.cpp for automatic speech recognition (ASR) and a Llama 3 model for style and grammar correction. The corrected text is then injected into the active application using IBus.

## Current Status

The following has been achieved:

*   **Model Selection and Loading:** A Llama 3 model in GGUF format has been selected and successfully loaded using llama-cli.
*   **Basic Inference:** The model's metadata and basic inference capabilities have been verified.
*   **Improve Script:** A script (`scripts/improve.sh`) has been created to take text from stdin, construct a combined prompt (instruction + text), and call llama-cli for style and grammar correction.
*   **Prompt Refinement:** The prompt has been refined to ensure the model returns only the corrected text, without explanations or lists.
*   **HTTP Daemon Prototype:** A Flask service with `/start` and `/stop` endpoints has been implemented to:
    *   Start a continuous ASR thread (Whisper.cpp) and queue the audio fragments.
    *   Process each fragment with the LLM for style correction.
    *   Inject the resulting text into the active application using IBus.
*   **End-to-End Flow Tests:** Validated that the daemon listens to the microphone, corrects each phrase, and sends it to the focused window after a `curl /start` command. The dictation can be stopped with `curl /stop`.

## Setup

To install dependencies, build the CLIs, and pull down default models automatically, run:

```bash
bash scripts/setup.sh
```

## Next Steps

*   **UI/UX Integration:**
    *   Add an "Empezar dictado" option in the context menu (right-click) of any text area.
    *   Detect the active focus and launch the `curl /start` or `curl /stop` commands accordingly.
*   **Robustecer ASR:**
    *   Improve audio segmentation based on silences.
    *   Consider other engines (VOSK, Porcupine for keyword activation, etc.).
*   **Afinar prompting:**
    *   Further refine the prompt to minimize unwanted comments and ensure only the correction of the text.
    *   Evaluate GBNF grammars if a strict format is desired (e.g., JSON with a single "text" field).
*   **Despliegue y autostart:**
    *   Configure the daemon to start when the user logs in.
    *   Package as a systemd service or similar.

