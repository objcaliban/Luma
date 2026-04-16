/// The single entry point for creating LLMKit services.
///
/// Assembles internal dependencies and returns only protocol types,
/// keeping all concrete implementations hidden from the main app.
///
/// ```swift
/// let factory = LLMKitFactory()
/// let provider = factory.makeModelProvider()
/// try await provider.load()
/// let chat = await factory.makeChatService(provider: provider)
/// ```
public struct LLMKitFactory: Sendable {

    private let modelID: String
    private let systemPrompt: String
    private let maxTokens: Int

    /// Creates a factory configured for a specific model.
    ///
    /// - Parameters:
    ///   - modelID: The Hugging Face model identifier.
    ///     Defaults to Llama 3.2 1B Instruct (4-bit quantized).
    ///   - systemPrompt: Instructions that define the assistant's behavior.
    ///   - maxTokens: Maximum number of tokens per response.
    public init(
        modelID: String = "mlx-community/Llama-3.2-1B-Instruct-4bit",
        systemPrompt: String = "You are a helpful assistant.",
        maxTokens: Int = 512
    ) {
        self.modelID = modelID
        self.systemPrompt = systemPrompt
        self.maxTokens = maxTokens
    }

    /// Creates a model provider that handles downloading and loading.
    ///
    /// - Returns: A ``ModelProvider`` ready to begin loading.
    public func makeModelProvider() -> any ModelProvider {
        let loader = HuggingFaceModelLoader(modelID: modelID)
        return DefaultModelProvider(loader: loader)
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
        guard let defaultProvider = provider as? DefaultModelProvider,
              let container = await defaultProvider.modelContainer else {
            throw LLMKitError.modelNotReady
        }

        let formatter = LlamaPromptFormatter(systemPrompt: systemPrompt)
        let generator = MLXTextGenerator()

        return DefaultChatService(
            formatter: formatter,
            generator: generator,
            container: container,
            maxTokens: maxTokens
        )
    }
}
