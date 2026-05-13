import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id: Int
    let author: String
    let text: String
    let dateTime: String
}

struct MessageDto: Decodable {
    let id: Int
    let username: String
    let content: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case content
        case createdAt
    }
}
