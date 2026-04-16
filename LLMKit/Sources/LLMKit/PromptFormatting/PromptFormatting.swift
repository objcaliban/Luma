/// Converts a conversation history into the format expected by the model.
///
/// Different model families (Llama, Mistral, etc.) use different chat templates.
/// This protocol isolates that formatting logic.
protocol PromptFormatting: Sendable {

    /// Formats a list of chat messages into the model's expected input structure.
    ///
    /// - Parameter messages: The conversation history.
    /// - Returns: An array of formatted messages ready for the tokenizer.
    func format(_ messages: [ChatMessage]) -> [FormattedMessage]
}
