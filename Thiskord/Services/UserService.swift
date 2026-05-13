import Foundation

struct UserService {
    private let api = ApiService.shared

    func getUsers(projectId: Int, token: String) async throws -> [UserAccount] {
        try await api.request("user/project/\(projectId)", method: "GET", token: token)
    }
}
