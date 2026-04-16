import Foundation

/// Errors that can occur when using LLMKit.
public enum LLMKitError: Error, LocalizedError, Sendable {

    /// The model provider has not finished loading. Call `load()` first.
    case modelNotReady

    /// A human-readable description of the error.
    public var errorDescription: String? {
        switch self {
        case .modelNotReady:
            return "The model is not loaded yet. Call load() on the provider first."
        }
    }
}
