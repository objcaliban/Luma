/// Formats a conversation history into the Llama Instruct chat template.
///
/// Llama 3.2 Instruct expects messages as role/content dictionaries
/// with roles: "system", "user", "assistant".
struct LlamaPromptFormatter: PromptFormatting {

    private let systemPrompt: String

    /// Creates a formatter with an optional system prompt.
    ///
    /// - Parameter systemPrompt: Instructions that define the assistant's behavior.
    init(systemPrompt: String = "You are a helpful assistant.") {
        self.systemPrompt = systemPrompt
    }

    func format(_ messages: [ChatMessage]) -> [[String: String]] {
        var formatted: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]

        for message in messages {
            formatted.append([
                "role": message.role.rawValue,
                "content": message.content
            ])
        }

        return formatted
    }
}
