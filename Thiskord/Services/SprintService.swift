import Foundation

struct SprintService {
    private let api = ApiService.shared

    func getSprints(projectId: Int, token: String) async throws -> [Sprint] {
        let primaryRoute = "sprint/sprint/project/\(projectId)"
        let fallbackRoute = "sprint/project/\(projectId)"

        do {
            let result = try await decodeSprints(route: primaryRoute, token: token)
            if !result.isEmpty {
                return result
            }
        } catch {
            // Try fallback route if primary fails.
        }

        return try await decodeSprints(route: fallbackRoute, token: token)
    }

    func createSprint(
        projectId: Int,
        goal: String,
        beginDate: String,
        endDate: String,
        token: String
    ) async throws {
        let payload = CreateSprintRequest(
            sprintGoal: goal,
            sprintBeginDate: beginDate,
            sprintEndDate: endDate,
            projectId: projectId
        )
        let data = try JSONEncoder().encode(payload)
        try await api.requestVoid("sprint/create/sprint", method: "POST", body: data, token: token)
    }
}

private extension SprintService {
    func decodeSprints(route: String, token: String) async throws -> [Sprint] {
        let data = try await api.requestData(route, method: "GET", token: token)
        if data.isEmpty {
            return []
        }

        if let sprints = try? JSONDecoder().decode([Sprint].self, from: data) {
            return sprints
        }
        if let wrapper = try? JSONDecoder().decode(SprintListWrapper.self, from: data),
           let sprints = wrapper.sprints {
            return sprints
        }
        if let wrapper = try? JSONDecoder().decode(SprintDataWrapper.self, from: data),
           let sprints = wrapper.data {
            return sprints
        }

        throw ApiError.decodingFailed(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Sprint response did not match expected shape.")))
    }
}

private struct SprintListWrapper: Decodable {
    let sprints: [Sprint]?
}

private struct SprintDataWrapper: Decodable {
    let data: [Sprint]?
}

private struct CreateSprintRequest: Encodable {
    let sprintGoal: String
    let sprintBeginDate: String
    let sprintEndDate: String
    let projectId: Int

    enum CodingKeys: String, CodingKey {
        case sprintGoal = "sprint_goal"
        case sprintBeginDate = "sprint_begin_date"
        case sprintEndDate = "sprint_end_date"
        case projectId = "id_project_sprint"
    }
}
