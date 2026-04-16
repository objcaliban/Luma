@preconcurrency import MLXLMCommon

/// Downloads (if not cached) and loads a language model into memory.
///
/// This protocol isolates the downloading and loading concern
/// from the rest of the package.
protocol ModelLoading: Sendable {

    /// Downloads and loads the model, reporting progress along the way.
    ///
    /// - Parameter onProgress: Called with a value from 0.0 to 1.0 as the download progresses.
    /// - Returns: A loaded model container ready for inference.
    func load(onProgress: @Sendable @escaping (Double) -> Void) async throws -> ModelContainer
}
