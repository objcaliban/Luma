import MLXLMCommon

/// Stateless service that coordinates prompt formatting and text generation.
struct MLXChatService: ChatService {

    private let formatter: any PromptFormatting
    private let generator: any TextGenerating
    private let container: ModelContainer
    private let maxTokens: Int

    /// Creates a chat service with its dependencies.
    ///
    /// - Parameters:
    ///   - formatter: Converts chat history into model input format.
    ///   - generator: Runs inference on the model.
    ///   - container: The loaded model to generate with.
    ///   - maxTokens: Maximum number of tokens per response.
    init(
        formatter: any PromptFormatting,
        generator: any TextGenerating,
        container: ModelContainer,
        maxTokens: Int = 512
    ) {
        self.formatter = formatter
        self.generator = generator
        self.container = container
        self.maxTokens = maxTokens
    }

    func sendStreaming(_ messages: [ChatMessage]) async throws -> AsyncStream<String> {
        let formatted = formatter.format(messages)
        return try await generator.generateStream(
            from: formatted,
            using: container,
            maxTokens: maxTokens
        )
    }
}
