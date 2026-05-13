import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageInput = ""
    @Published var errorMessage = ""
    @Published var isEditing = false

    private let chatService = ChatService.shared
    private var editingMessageId: Int?

    func connectAndJoin(channel: Channel, token: String) async {
        messages = []
        errorMessage = ""

        chatService.onMessageReceived = { [weak self] message in
            Task { @MainActor in
                self?.messages.append(message)
            }
        }
        chatService.onMessageDeleted = { [weak self] messageId in
            Task { @MainActor in
                self?.messages.removeAll { $0.id == messageId }
            }
        }
        chatService.onMessageEdited = { [weak self] message in
            Task { @MainActor in
                if let index = self?.messages.firstIndex(where: { $0.id == message.id }) {
                    let existing = self?.messages[index]
                    let updated = ChatMessage(
                        id: message.id,
                        author: existing?.author ?? message.author,
                        text: message.text,
                        dateTime: message.dateTime
                    )
                    self?.messages[index] = updated
                }
            }
        }

        do {
            try await chatService.connect(token: token)
            if let channelId = channel.id {
                try await chatService.joinChannel(channelId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveChannel() async {
        do {
            try await chatService.leaveChannel()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func prepareEdit(_ message: ChatMessage) {
        isEditing = true
        editingMessageId = message.id
        messageInput = message.text
    }

    func cancelEdit() {
        isEditing = false
        editingMessageId = nil
        messageInput = ""
    }

    func send() async {
        let trimmed = messageInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messageInput = ""

        do {
            if isEditing, let editingMessageId {
                try await chatService.editMessage(editingMessageId, text: trimmed)
                cancelEdit()
            } else {
                try await chatService.sendMessage(trimmed)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ message: ChatMessage) async {
        do {
            try await chatService.deleteMessage(message.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
