import SwiftUI
import LLMKit

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    private var markdownContent: AttributedString {
        (try? AttributedString(markdown: message.content)) ?? AttributedString(message.content)
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(markdownContent)
                .padding(12)
                .background(isUser ? Color.accentColor : Color(.secondarySystemFill))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isUser { Spacer(minLength: 60) }
        }
    }
}
