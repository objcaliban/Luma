/// A service that manages a chat conversation with a language model.
///
/// Consumers send messages and receive assistant responses.
/// The service maintains conversation history internally.
///
/// Conforms to `Sendable` so it can be safely passed across actor boundaries.
public protocol ChatService: Sendable {

    /// Sends a user message and returns the assistant's response.
    ///
    /// The implementation is responsible for formatting the prompt,
    /// running inference, and returning generated text.
    ///
    /// - Parameter message: The user's input text.
    /// - Returns: The assistant's response as a ``ChatMessage``.
    /// - Throws: An error if inference fails.
    func send(_ message: String) async throws -> ChatMessage

    /// The full conversation history, ordered chronologically.
    var history: [ChatMessage] { get async }
}
