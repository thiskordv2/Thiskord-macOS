import Foundation

struct ProjectService {
    private let api = ApiService.shared

    func getAllProjects(token: String) async throws -> [Project] {
        try await api.request("project/all", method: "GET", token: token)
    }

    func createProject(name: String, description: String, token: String) async throws {
        let payload = CreateProjectRequest(name: name, description: description)
        let data = try JSONEncoder().encode(payload)
        try await api.requestVoid("project/create", method: "POST", body: data, token: token)
    }

    func updateProject(projectId: Int, name: String, description: String, token: String) async throws {
        let payload = UpdateProjectRequest(name: name, description: description)
        let data = try JSONEncoder().encode(payload)
        try await api.requestVoid("project/\(projectId)", method: "PUT", body: data, token: token)
    }

    func deleteProject(projectId: Int, token: String) async throws {
        try await api.requestVoid("project/\(projectId)", method: "DELETE", token: token)
    }

    func inviteToProject(projectId: Int, expiresAt: String, token: String) async throws -> String? {
        let payload = InviteRequest(projectId: projectId, expiresAt: expiresAt)
        let data = try JSONEncoder().encode(payload)
        let result: InviteResponse = try await api.request("invite", method: "POST", body: data, token: token)
        return result.inviteToken ?? result.error
    }

    func joinProject(token: String, authToken: String) async throws -> String? {
        let result: JoinProjectResponse = try await api.request("invite/\(token)", method: "POST", token: authToken)
        return result.message ?? result.error
    }
}

private struct CreateProjectRequest: Encodable {
    let name: String
    let description: String
}

private struct UpdateProjectRequest: Encodable {
    let name: String
    let description: String
}

private struct InviteRequest: Encodable {
    let projectId: Int
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case projectId
        case expiresAt
    }
}

private struct InviteResponse: Decodable {
    let inviteToken: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case inviteToken
        case error
    }
}

private struct JoinProjectResponse: Decodable {
    let message: String?
    let error: String?
}
