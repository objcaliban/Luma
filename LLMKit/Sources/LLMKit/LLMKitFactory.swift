/// The single entry point for creating LLMKit services.
///
/// - Note - possible improvement: extract a protocol for `LLMKitFactory` if multiple implementations are needed;
///   omitted for simplicity given the scope of the task
public struct LLMKitFactory: Sendable {

    private let modelID: String
    private let maxTokens: Int

    /// Creates a factory configured for a specific model.
    ///
    /// - Parameters:
    ///   - modelID: The Hugging Face model identifier.
    ///     Defaults to Llama 3.2 1B Instruct (4-bit quantized).
    ///   - maxTokens: Maximum number of tokens per response.
    public init(
        /// - Note - possible improvement: move modelID to some local or remote configuration
        modelID: String = "mlx-community/Llama-3.2-1B-Instruct-4bit",
        maxTokens: Int = 512
    ) {
        self.modelID = modelID
        self.maxTokens = maxTokens
    }

    /// Creates a model provider that handles downloading and loading.
    ///
    /// - Returns: A ``ModelProvider`` ready to begin loading.
    public func makeModelProvider() -> any ModelProvider {
        let loader = HuggingFaceModelLoader(modelID: modelID)
        return MLXModelProvider(loader: loader)
    }

    /// Creates a chat service using a loaded model provider.
    ///
    /// The provider must be in the ``ModelState/ready`` state.
    /// Call ``ModelProvider/load()`` before calling this method.
    ///
    /// - Parameter provider: A provider that has finished loading the model.
    /// - Returns: A ``ChatService`` ready to accept messages.
    /// - Throws: ``LLMKitError/modelNotReady`` if the provider has no loaded model.
    public func makeChatService(provider: any ModelProvider) async throws -> any ChatService {
        guard let container = await provider.modelContainer else {
            throw LLMKitError.modelNotReady
        }

        /// - Note - possible improvement: inject formatter and generator via init for testability and flexibility,
        ///   depending on the desired API architecture
        let formatter = ChatPromptFormatter()
        let generator = MLXTextGenerator()

        return MLXChatService(
            formatter: formatter,
            generator: generator,
            container: container,
            maxTokens: maxTokens
        )
    }
}
