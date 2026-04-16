@preconcurrency import MLXLMCommon

/// Manages the model lifecycle: downloading, loading, and exposing the loaded container.
///
/// Uses an actor to safely manage mutable state (`currentState` and `container`)
/// across concurrent access.
actor DefaultModelProvider: ModelProvider {

    private let loader: any ModelLoading
    private var currentState: ModelState = .idle
    private var container: ModelContainer?

    /// Creates a provider that delegates loading to the given loader.
    ///
    /// - Parameter loader: The strategy used to download and load the model.
    init(loader: any ModelLoading) {
        self.loader = loader
    }

    var state: ModelState {
        currentState
    }

    /// The loaded model container.
    ///
    /// Returns `nil` if the model has not been loaded yet.
    var modelContainer: ModelContainer? {
        container
    }

    func load() async throws {
        currentState = .downloading(progress: 0.0)

        do {
            let loaded = try await loader.load { [weak self] progress in
                Task { await self?.updateProgress(progress) }
            }
            container = loaded
            currentState = .ready
        } catch {
            currentState = .failed(error)
            throw error
        }
    }

    private func updateProgress(_ progress: Double) {
        guard case .downloading = currentState else { return }
        currentState = .downloading(progress: progress)
    }
}
