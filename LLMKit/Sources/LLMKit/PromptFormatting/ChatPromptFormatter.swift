/// Formats a conversation history into the standard chat completion format.
/// Produces role/content dictionaries compatible with most chat models that use the OpenAI-style message format.
///
/// - Note possible improvement: Depending on the use case, a `systemPrompt` could be added here
struct ChatPromptFormatter: PromptFormatting {

    func format(_ messages: [ChatMessage]) -> [FormattedMessage] {
        messages.map { FormattedMessage(role: $0.role.rawValue, content: $0.content) }
    }
}
