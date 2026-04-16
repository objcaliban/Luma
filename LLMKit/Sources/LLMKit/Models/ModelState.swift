/// Represents the current state of the language model lifecycle.
public enum ModelState: Sendable {

    /// The model has not been loaded yet.
    case idle

    /// The model is being downloaded.
    case downloading

    /// The model is loaded into memory and ready for inference.
    case ready

    /// The model failed to load.
    case failed(Error)
}
