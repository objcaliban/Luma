@preconcurrency import MLXLMCommon

/// Orchestrates a chat conversation by coordinating prompt formatting and text generation.
///
/// Uses an actor to safely manage the mutable conversation history.
actor DefaultChatService: ChatService {

    private let formatter: any PromptFormatting
    private let generator: any TextGenerating
    private let container: ModelContainer
    private let maxTokens: Int
    private var messages: [ChatMessage] = []

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

    var history: [ChatMessage] {
        messages
    }

    func send(_ message: String) async throws -> ChatMessage {
        let userMessage = ChatMessage(role: .user, content: message)
        messages.append(userMessage)

        let formatted = formatter.format(messages)
        let responseText = try await generator.generate(
            from: formatted,
            using: container,
            maxTokens: maxTokens
        )

        let assistantMessage = ChatMessage(role: .assistant, content: responseText)
        messages.append(assistantMessage)

        return assistantMessage
    }

    func sendStreaming(_ message: String) async throws -> AsyncThrowingStream<String, Error> {
        let userMessage = ChatMessage(role: .user, content: message)
        messages.append(userMessage)

        let formatted = formatter.format(messages)
        let innerStream = try await generator.generateStream(
            from: formatted,
            using: container,
            maxTokens: maxTokens
        )

        // Wrap to capture the full response for history once streaming completes
        return AsyncThrowingStream { [weak self] continuation in
            Task { [weak self] in
                var fullResponse = ""
                do {
                    for try await chunk in innerStream {
                        fullResponse += chunk
                        continuation.yield(chunk)
                    }
                    await self?.appendAssistantMessage(fullResponse)
                    continuation.finish()
                } catch {
                    await self?.appendAssistantMessage(fullResponse)
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func appendAssistantMessage(_ content: String) {
        messages.append(ChatMessage(role: .assistant, content: content))
    }
}
