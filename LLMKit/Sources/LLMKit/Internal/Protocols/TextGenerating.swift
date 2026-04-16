@preconcurrency import MLXLMCommon

/// Runs inference on a loaded model and returns generated text.
///
/// This protocol isolates the inference concern from prompt formatting
/// and model loading.
protocol TextGenerating: Sendable {

    /// Generates text from a formatted conversation.
    ///
    /// - Parameters:
    ///   - messages: Role/content pairs in the model's expected format.
    ///   - container: The loaded model container to run inference on.
    ///   - maxTokens: The maximum number of tokens to generate.
    /// - Returns: The generated text.
    func generate(
        from messages: [[String: String]],
        using container: ModelContainer,
        maxTokens: Int
    ) async throws -> String

    /// Streams generated text chunks from a formatted conversation.
    ///
    /// - Parameters:
    ///   - messages: Role/content pairs in the model's expected format.
    ///   - container: The loaded model container to run inference on.
    ///   - maxTokens: The maximum number of tokens to generate.
    /// - Returns: An async stream of text chunks.
    func generateStream(
        from messages: [[String: String]],
        using container: ModelContainer,
        maxTokens: Int
    ) async throws -> AsyncThrowingStream<String, Error>
}
