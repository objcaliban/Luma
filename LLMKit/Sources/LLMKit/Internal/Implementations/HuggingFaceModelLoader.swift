import MLXLLM
import MLXLMCommon

/// Downloads a model from Hugging Face Hub and loads it into memory.
///
/// Uses `LLMModelFactory` from MLXLLM (v2) for downloading and loading.
/// Models are cached locally after the first download.
struct HuggingFaceModelLoader: ModelLoading {

    private let modelID: String

    /// Creates a loader for the given Hugging Face model identifier.
    ///
    /// - Parameter modelID: The Hugging Face model ID (e.g. "mlx-community/Llama-3.2-1B-Instruct-4bit").
    init(modelID: String) {
        self.modelID = modelID
    }

    func load(onProgress: @Sendable @escaping (Double) -> Void) async throws -> ModelContainer {
        let configuration = ModelConfiguration(id: modelID)
        // LLMModelFactory.shared is the library-provided entry point in mlx-swift-lm v2.
        // We cannot avoid it — it is the only public API for loading models.
        return try await LLMModelFactory.shared.loadContainer(
            configuration: configuration
        ) { progress in
            onProgress(progress.fractionCompleted)
        }
    }
}
