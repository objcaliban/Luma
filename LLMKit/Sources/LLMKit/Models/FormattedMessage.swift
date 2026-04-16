/// A single role/content pair formatted for the model's tokenizer.
struct FormattedMessage: Sendable {
    let role: String
    let content: String

    /// Converts to the dictionary format expected by MLXLMCommon's `UserInput`.
    var asDictionary: [String: String] {
        ["role": role, "content": content]
    }
}
