import MLXLMCommon

/// Runs inference on a loaded model and returns generated text.
protocol TextGenerating: Sendable {

    /// Streams generated text chunks from a formatted conversation.
    ///
    /// - Parameters:
    ///   - messages: Role/content pairs in the model's expected format.
    ///   - container: The loaded model container to run inference on.
    ///   - maxTokens: The maximum number of tokens to generate.
    /// - Returns: An async stream of text chunks.
    func generateStream(
        from messages: [FormattedMessage],
        using container: ModelContainer,
        maxTokens: Int
    ) async throws -> AsyncStream<String>
}
