import SwiftUI
import LLMKit

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            Divider()
            inputBar
        }
        .task {
            await viewModel.loadModel()
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "brain")
                .foregroundStyle(.secondary)
            Text("Luma")
                .font(.headline)
            Spacer()
            statusBadge
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var statusBadge: some View {
        Group {
            switch viewModel.modelState {
            case .ready:
                Label("Ready", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            case .failed:
                Label("Error", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            default:
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Preparing model...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 30)
    }

    /// - Note - possible improvement: add auto-scroll to the latest message on content updates;
    ///   simplified given the scope of the task
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isGenerating {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Thinking...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .id("typing")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) {
                withAnimation {
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message...", text: $viewModel.inputText)
                .textFieldStyle(.plain)
                .onSubmit { sendMessage() }
                .disabled(!viewModel.isReady)

            if viewModel.isGenerating {
                Button(action: { viewModel.cancelGeneration() }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            } else {
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.canSend ? .primary : .secondary)
                .disabled(!viewModel.canSend)
            }
        }
        .padding(12)
    }

    private func sendMessage() {
        guard viewModel.canSend else { return }
        viewModel.sendMessage()
    }
}
