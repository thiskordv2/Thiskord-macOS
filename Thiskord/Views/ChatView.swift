import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var session: SessionStore
    let selectedChannel: Channel?

    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 12) {
            if let selectedChannel {
                Text("Channel: \(selectedChannel.displayName)")
                    .font(.callout)
            } else {
                Text("Select a channel to start chatting.")
                    .font(.callout)
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(message.author)
                                    Text(message.dateTime)
                                        .font(.caption)
                                    Spacer()
                                    Menu {
                                        Button("Edit") { viewModel.prepareEdit(message) }
                                        Button("Delete", role: .destructive) {
                                            Task { await viewModel.delete(message) }
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.caption)
                                    }
                                    .menuStyle(.borderlessButton)
                                    .fixedSize()
                                }
                                Text(message.text)
                            }
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Message", text: $viewModel.messageInput)
                Button("Send") {
                    Task { await viewModel.send() }
                }
                if viewModel.isEditing {
                    Button("Cancel") {
                        viewModel.cancelEdit()
                    }
                }
            }
        }
        .padding(16)
        .onChange(of: selectedChannel?.id) { _, _ in
            Task { await viewModel.leaveChannel() }
            if let selectedChannel {
                Task { await viewModel.connectAndJoin(channel: selectedChannel, token: session.token) }
            }
        }
        .task {
            if let selectedChannel {
                await viewModel.connectAndJoin(channel: selectedChannel, token: session.token)
            }
        }
    }
}
