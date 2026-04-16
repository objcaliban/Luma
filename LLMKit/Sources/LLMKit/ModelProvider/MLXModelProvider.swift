import MLXLMCommon

/// Manages the model lifecycle: downloading, loading, and exposing the loaded container.
actor MLXModelProvider: ModelProvider {
    var state: ModelState {
        currentState
    }
    
    /// The loaded model container.
    ///
    /// Returns `nil` if the model has not been loaded yet.
    var modelContainer: ModelContainer? {
        container
    }
    
    private let loader: any ModelLoading
    private var currentState: ModelState = .idle
    private var container: ModelContainer?

    /// Creates a provider that delegates loading to the given loader.
    ///
    /// - Parameter loader: The strategy used to download and load the model.
    init(loader: any ModelLoading) {
        self.loader = loader
    }

    func load() async throws {
        currentState = .downloading

        do {
            let loaded = try await loader.load()
            container = loaded
            currentState = .ready
        } catch {
            currentState = .failed(error)
            throw error
        }
    }
}
