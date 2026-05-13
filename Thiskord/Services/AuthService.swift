import Foundation

struct AuthService {
    private let api = ApiService.shared

    func login(username: String, password: String) async throws -> AuthenticatedUser {
        let payload = AuthRequest(userAuth: username, password: password)
        let json = try JSONEncoder().encode(payload)
        return try await api.request("auth/auth", method: "POST", body: json)
    }
}
