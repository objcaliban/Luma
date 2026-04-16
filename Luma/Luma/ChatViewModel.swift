import SwiftUI
import LLMKit

@Observable
final class ChatViewModel {
    @MainActor var inputText = ""

    @MainActor private(set) var messages: [ChatMessage] = []
    @MainActor private(set) var modelState: ModelState = .idle
    @MainActor private(set) var isGenerating = false

    private let factory: LLMKitFactory
    private var provider: (any ModelProvider)?
    private var chatService: (any ChatService)?
    private var generateTask: Task<Void, Never>?

    /// - Note - possible improvement: accept a protocol instead of a concrete type for full testability;
    ///   simplified given the scope of the task
    init(factory: LLMKitFactory = LLMKitFactory()) {
        self.factory = factory
    }

    func loadModel() async {
        guard await modelState.canAttemptLoading else { return }

        await MainActor.run { modelState = .downloading }
        let provider = factory.makeModelProvider()
        self.provider = provider

        do {
            try await provider.load()
            let state = await provider.state
            let service = try await factory.makeChatService(provider: provider)
            await MainActor.run {
                modelState = state
                chatService = service
            }
        } catch {
            await MainActor.run { modelState = .failed(error) }
        }
    }
    
    func sendMessage() {
        generateTask = Task {
            await send()
            generateTask = nil
        }
    }

    func cancelGeneration() {
        generateTask?.cancel()
    }

    @MainActor
    private func send() async {
        guard !isGenerating else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, chatService != nil else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        let responseID = UUID()
        let responseTimestamp = Date()
        messages.append(ChatMessage(role: .assistant, content: "", id: responseID, timestamp: responseTimestamp))
        isGenerating = true

        await performGeneration(responseID: responseID, responseTimestamp: responseTimestamp)

        isGenerating = false
    }

    private func performGeneration(responseID: UUID, responseTimestamp: Date) async {
        guard let chatService else { return }

        var chunks: [String] = []
        do {
            let stream = try await chatService.sendStreaming(messages)
            for await chunk in stream {
                try Task.checkCancellation()
                chunks.append(chunk)
                let accumulated = chunks.joined()
                await MainActor.run {
                    updateMessage(id: responseID, content: accumulated, timestamp: responseTimestamp)
                }
            }
        } catch is CancellationError {
            // Generation was cancelled by the user
        } catch {
            if chunks.isEmpty {
                await MainActor.run {
                    updateMessage(id: responseID, content: "Error: \(error.localizedDescription)", timestamp: responseTimestamp)
                }
            }
        }
    }

    @MainActor
    private func updateMessage(id: UUID, content: String, timestamp: Date) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index] = ChatMessage(role: .assistant, content: content, id: id, timestamp: timestamp)
    }
}
