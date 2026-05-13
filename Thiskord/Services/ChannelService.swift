import Foundation

struct ChannelService {
    private let api = ApiService.shared

    func getChannels(projectId: Int, token: String) async throws -> [Channel] {
        let data = try await api.requestData("channel/project/\(projectId)", method: "GET", token: token)
        if data.isEmpty {
            return []
        }

        if let channels = try? JSONDecoder().decode([Channel].self, from: data) {
            return channels
        }
        if let wrapper = try? JSONDecoder().decode(ChannelListWrapper.self, from: data),
           let channels = wrapper.channels {
            return channels
        }
        if let wrapper = try? JSONDecoder().decode(ChannelDataWrapper.self, from: data),
           let channels = wrapper.data {
            return channels
        }

        let snippet = String(data: data, encoding: .utf8) ?? "<non-utf8>"
        throw ChannelDecodingError(responseSnippet: String(snippet.prefix(500)))
    }

    func createChannel(
        name: String,
        description: String,
        projectId: Int,
        token: String
    ) async throws {
        let payload = CreateChannelRequest(
            name: name,
            description: description,
            projectId: projectId
        )
        let data = try JSONEncoder().encode(payload)
        try await api.requestVoid("channel/create", method: "POST", body: data, token: token)
    }

    func updateChannel(
        channelId: Int,
        name: String,
        description: String,
        token: String
    ) async throws {
        let payload = UpdateChannelRequest(name: name, description: description)
        let data = try JSONEncoder().encode(payload)
        try await api.requestVoid("channel/\(channelId)", method: "PUT", body: data, token: token)
    }

    func deleteChannel(channelId: Int, token: String) async throws {
        try await api.requestVoid("channel/\(channelId)", method: "DELETE", token: token)
    }
}

private struct ChannelListWrapper: Decodable {
    let channels: [Channel]?
}

private struct ChannelDataWrapper: Decodable {
    let data: [Channel]?
}

private struct ChannelDecodingError: LocalizedError {
    let responseSnippet: String

    var errorDescription: String? {
        "Channels decode failed. Response: \(responseSnippet)"
    }
}

private struct CreateChannelRequest: Encodable {
    let name: String
    let description: String
    let projectId: Int

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case projectId
    }
}

private struct UpdateChannelRequest: Encodable {
    let name: String
    let description: String
}
