/// A provider that manages downloading and loading a language model.
///
/// The main app observes ``state`` to display loading progress in the UI,
/// and calls ``load()`` to initiate the download-and-load sequence.
///
/// Conforms to `Sendable` so it can be safely passed across actor boundaries.
public protocol ModelProvider: Sendable {

    /// The current state of the model lifecycle.
    var state: ModelState { get async }

    /// Downloads (if needed) and loads the model into memory.
    ///
    /// After this method returns successfully, ``state`` is ``ModelState/ready``.
    /// Progress updates are reflected in ``state`` as ``ModelState/downloading(progress:)``.
    ///
    /// - Throws: An error if downloading or loading fails.
    func load() async throws
}
