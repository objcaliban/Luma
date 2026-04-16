import MLXLMCommon

/// A provider that manages downloading and loading a language model.
public protocol ModelProvider: Sendable {

    /// The current state of the model lifecycle.
    var state: ModelState { get async }

    /// The loaded model container, or `nil` if the model has not been loaded yet.
    var modelContainer: ModelContainer? { get async }

    /// Downloads (if needed) and loads the model into memory.
    /// - Throws: An error if downloading or loading fails.
    func load() async throws
}
