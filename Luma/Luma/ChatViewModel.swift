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
        messages.append(ChatMessage(role: .assistant, content: ""))
        isGenerating = true

        do {
            let stream = try await chatService.sendStreaming(text)
            for try await chunk in stream {
                messages[messages.count - 1].content += chunk
            }
        } catch {
            if messages[messages.count - 1].content.isEmpty {
                messages[messages.count - 1].content = "Error: \(error.localizedDescription)"
            }
        }

        isGenerating = false
    }
}
