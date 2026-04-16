@preconcurrency import MLXLMCommon

/// Runs inference on a loaded MLX model and returns generated text.
///
/// Handles tokenization of formatted messages, autoregressive generation,
/// and decoding of output tokens.
struct MLXTextGenerator: TextGenerating {

    private let temperature: Float
    private let topP: Float

    /// Creates a generator with sampling parameters.
    ///
    /// - Parameters:
    ///   - temperature: Controls randomness. Lower values produce more deterministic output.
    ///   - topP: Nucleus sampling threshold. Only tokens within this cumulative probability are considered.
    init(temperature: Float = 0.7, topP: Float = 0.9) {
        self.temperature = temperature
        self.topP = topP
    }

    func generate(
        from messages: [[String: String]],
        using container: ModelContainer,
        maxTokens: Int
    ) async throws -> String {
        let input = try await container.perform { context in
            try await context.processor.prepare(input: .init(messages: messages))
        }

        let result = try await container.perform { context in
            try MLXLMCommon.generate(
                input: input,
                parameters: .init(temperature: temperature, topP: topP),
                context: context
            ) { tokens in
                tokens.count >= maxTokens ? .stop : .more
            }
        }

        return result.output
    }

    func generateStream(
        from messages: [[String: String]],
        using container: ModelContainer,
        maxTokens: Int
    ) async throws -> AsyncThrowingStream<String, Error> {
        let input = try await container.perform { context in
            try await context.processor.prepare(input: .init(messages: messages))
        }

        let parameters = GenerateParameters(maxTokens: maxTokens, temperature: temperature, topP: topP)
        let stream = try await container.generate(input: input, parameters: parameters)

        return AsyncThrowingStream { continuation in
            Task {
                for await generation in stream {
                    if let chunk = generation.chunk {
                        continuation.yield(chunk)
                    }
                }
                continuation.finish()
            }
        }
    }
}
