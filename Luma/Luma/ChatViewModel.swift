import SwiftUI
import LLMKit

@Observable
final class ChatViewModel {
    var inputText = ""
    
    private(set) var messages: [ChatMessage] = []
    private(set) var modelState: ModelState = .idle
    private(set) var isGenerating = false

    private let factory: LLMKitFactory
    private var provider: (any ModelProvider)?
    private var chatService: (any ChatService)?

    /// - Note - possible improvement: accept a protocol instead of a concrete type for full testability;
    ///   simplified given the scope of the task
    init(factory: LLMKitFactory = LLMKitFactory()) {
        self.factory = factory
    }

    func loadModel() async {
        guard modelState.canAttemptLoading else { return }

        modelState = .downloading
        let provider = factory.makeModelProvider()
        self.provider = provider

        do {
            try await provider.load()
            modelState = await provider.state
            chatService = try await factory.makeChatService(provider: provider)
        } catch {
            modelState = .failed(error)
        }
    }

    func send() async {
        guard !isGenerating else { return }
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let chatService else { return }

        inputText = ""
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        let responseID = UUID()
        let responseTimestamp = Date()
        messages.append(ChatMessage(role: .assistant, content: "", id: responseID, timestamp: responseTimestamp))
        isGenerating = true

        var chunks: [String] = []
        do {
            let stream = try await chatService.sendStreaming(messages)
            for await chunk in stream {
                chunks.append(chunk)
                let accumulated = chunks.joined()
                updateMessage(id: responseID, content: accumulated, timestamp: responseTimestamp)
            }
        } catch {
            if chunks.isEmpty {
                updateMessage(id: responseID, content: "Error: \(error.localizedDescription)", timestamp: responseTimestamp)
            }
        }

        isGenerating = false
    }

    private func updateMessage(id: UUID, content: String, timestamp: Date) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index] = ChatMessage(role: .assistant, content: content, id: id, timestamp: timestamp)
    }
}
