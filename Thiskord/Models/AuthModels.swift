import Foundation

struct AuthRequest: Encodable {
    let userAuth: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case userAuth = "user_auth"
        case password
    }
}

struct User: Decodable {
    let userId: Int?
    let userName: String
    let userMail: String
    let userPicture: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userName = "user_name"
        case userMail = "user_mail"
        case userPicture = "user_picture"
    }
}

struct AuthenticatedUser: Decodable {
    let user: User
    let token: String
}
