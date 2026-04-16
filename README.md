# Luma

A native macOS chat application that runs a large language model entirely on-device using [MLX](https://github.com/ml-explore/mlx-swift-lm).

## Summary

Luma is a SwiftUI-based chat interface backed by a local LLM. It downloads and loads a quantized Llama 3.2 1B Instruct model via Hugging Face, then streams responses token-by-token — all without any external API calls or network requests at inference time.

The project is split into two modules:

- **Luma** (Xcode app target) — the SwiftUI application with a chat UI, view model, and message bubbles.
- **LLMKit** (Swift Package) — a reusable library that wraps MLX Swift for model downloading, loading, prompt formatting, and streaming text generation.

### How It Works

1. On launch, `ChatViewModel` asks `LLMKit` to download and load the model into memory.
2. The UI shows a status badge (downloading / ready / error) reflecting the model lifecycle (`ModelState`).
3. When the user sends a message, `ChatViewModel` passes the full conversation history to `ChatService.sendStreaming(_:)`, which formats the prompt, runs inference via MLX, and returns an `AsyncStream<String>` of token chunks.
4. The view model accumulates chunks and updates the assistant message in real time, giving a streaming "typing" effect.
5. The user can cancel an in-progress generation at any time.

## Build & Run

1. Clone the repository

2. Open the Xcode project

3. Xcode will automatically resolve the `LLMKit` local package and its `mlx-swift-lm` dependency. Wait for package resolution to complete.

4. Select the **Luma** scheme and an Apple Silicon Mac as the run destination.

5. Build and run.

On the first launch the app will download the Llama 3.2 1B model (~700 MB). Subsequent launches load from the local cache and are much faster.

## Testing

The project currently does not include a test target.
