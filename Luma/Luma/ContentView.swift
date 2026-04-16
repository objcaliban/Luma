import SwiftUI
import LLMKit

struct ContentView: View {
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
                .disabled(!isReady)

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
                .foregroundStyle(canSend ? .primary : .secondary)
                .disabled(!canSend)
            }
        }
        .padding(12)
    }

    private var isReady: Bool {
        if case .ready = viewModel.modelState { return true }
        return false
    }

    private var canSend: Bool {
        isReady && !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isGenerating
    }

    private func sendMessage() {
        guard canSend else { return }
        viewModel.sendMessage()
    }
}
