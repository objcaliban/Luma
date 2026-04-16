import SwiftUI
import LLMKit

@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var modelState: ModelState = .idle
    private(set) var isGenerating = false

    var inputText = ""

    private let factory = LLMKitFactory()
    private var provider: (any ModelProvider)?
    private var chatService: (any ChatService)?

    func loadModel() async {
        if case .ready = modelState { return }

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

    func refreshModelState() async {
        guard let provider else { return }
        modelState = await provider.state
    }

    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let chatService else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))
        isGenerating = true

        do {
            let response = try await chatService.send(text)
            // Replace history with service's version to stay in sync
            messages = await chatService.history
            _ = response // response is already in history
        } catch {
            messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
        }

        isGenerating = false
    }
}
