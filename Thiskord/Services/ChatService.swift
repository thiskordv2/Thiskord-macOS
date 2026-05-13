import Foundation
import SignalRClient

final class ChatService {
    static let shared = ChatService()

    private var connection: HubConnection?
    private var isStarted = false
    private var currentChannelId: Int?

    var onMessageReceived: ((ChatMessage) -> Void)?
    var onMessageDeleted: ((Int) -> Void)?
    var onMessageEdited: ((ChatMessage) -> Void)?

    private init() {}

    func connect(token: String) async throws {
        if isStarted { return }

        let url = URL(string: "https://api.emre-ak.fr/chatHub")!
        let hub = HubConnectionBuilder(url: url)
            .withHttpConnectionOptions(configureHttpOptions: { options in
                options.accessTokenProvider = { token }
            })
            .withAutoReconnect()
            .build()

        hub.on(method: "LoadMessages", callback: { [weak self] (messages: [MessageDto]) in
            for message in messages {
                let mapped = ChatMessage(
                    id: message.id,
                    author: message.username,
                    text: message.content,
                    dateTime: message.createdAt
                )
                self?.onMessageReceived?(mapped)
            }
        })

        hub.on(method: "ReceiveMessage", callback: { [weak self] (id: Int, user: String, text: String, dateTime: String) in
            let message = ChatMessage(id: id, author: user, text: text, dateTime: dateTime)
            self?.onMessageReceived?(message)
        })

        hub.on(method: "DeleteMessage", callback: { [weak self] (messageId: Int) in
            self?.onMessageDeleted?(messageId)
        })

        hub.on(method: "EditMessage", callback: { [weak self] (messageId: Int, newText: String, updatedAt: String) in
            let message = ChatMessage(id: messageId, author: "", text: newText, dateTime: updatedAt)
            self?.onMessageEdited?(message)
        })

        connection = hub
        hub.start()
        isStarted = true
    }

    func joinChannel(_ channelId: Int) async throws {
        guard let connection else { return }
        if let currentChannelId {
            connection.invoke(method: "LeaveChannel", arguments: [currentChannelId], invocationDidComplete: { _ in })
        }
        connection.invoke(method: "JoinChannel", arguments: [channelId], invocationDidComplete: { _ in })
        self.currentChannelId = channelId
    }

    func leaveChannel() async throws {
        guard let connection, let currentChannelId else { return }
        connection.invoke(method: "LeaveChannel", arguments: [currentChannelId], invocationDidComplete: { _ in })
        self.currentChannelId = nil
    }

    func sendMessage(_ text: String) async throws {
        guard let connection, let currentChannelId else { return }
        connection.invoke(method: "SendMessage", arguments: [currentChannelId, text], invocationDidComplete: { _ in })
    }

    func deleteMessage(_ messageId: Int) async throws {
        guard let connection, let currentChannelId else { return }
        connection.invoke(method: "DeleteMessage", arguments: [currentChannelId, messageId], invocationDidComplete: { _ in })
    }

    func editMessage(_ messageId: Int, text: String) async throws {
        guard let connection, let currentChannelId else { return }
        connection.invoke(method: "EditMessage", arguments: [currentChannelId, messageId, text], invocationDidComplete: { _ in })
    }
}
