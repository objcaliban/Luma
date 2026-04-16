import MLXLMCommon

/// Downloads (if not cached) and loads a language model into memory.
///
/// This protocol isolates the downloading and loading concern
/// from the rest of the package.
protocol ModelLoading: Sendable {

    /// Downloads and loads the model.
    ///
    /// - Returns: A loaded model container ready for inference.
    func load() async throws -> ModelContainer
}
