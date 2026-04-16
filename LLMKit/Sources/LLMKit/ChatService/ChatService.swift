/// A stateless service that generates assistant responses from a conversation.
///
/// The caller owns the conversation history and passes it with each request.
///
/// Conforms to `Sendable` so it can be safely passed across actor boundaries.
public protocol ChatService: Sendable {

    /// Streams an assistant response for the given conversation.
    ///
    /// - Parameter messages: The full conversation history including the latest user message.
    /// - Returns: An async stream of generated text chunks.
    func sendStreaming(_ messages: [ChatMessage]) async throws -> AsyncStream<String>
}
