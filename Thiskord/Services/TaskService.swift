import Foundation

struct TaskService {
    private let api = ApiService.shared

    func getTasksBySprint(sprintId: Int, token: String) async throws -> [SprintTask] {
        let data = try await api.requestData("sprinttask/sprint/task/\(sprintId)", method: "GET", token: token)
        if data.isEmpty {
            return []
        }

        if let tasks = try? JSONDecoder().decode([SprintTask].self, from: data) {
            return tasks
        }
        if let wrapper = try? JSONDecoder().decode(TaskListWrapper.self, from: data),
           let tasks = wrapper.tasks {
            return tasks
        }
        if let wrapper = try? JSONDecoder().decode(TaskDataWrapper.self, from: data),
           let tasks = wrapper.data {
            return tasks
        }

        let snippet = String(data: data, encoding: .utf8) ?? "<non-utf8>"
        throw TaskDecodingError(responseSnippet: String(snippet.prefix(500)))
    }

    func createTask(_ request: CreateTaskRequest, token: String) async throws {
        let data = try JSONEncoder().encode(request)
        do {
            try await api.requestVoid("sprinttask/task", method: "POST", body: data, token: token)
        } catch {
            if case ApiError.decodingFailed = error {
                return
            }
            throw error
        }
    }

    func deleteTask(taskId: Int, token: String) async throws {
        try await api.requestVoid("sprinttask/task/\(taskId)", method: "DELETE", token: token)
    }
}

private struct TaskListWrapper: Decodable {
    let tasks: [SprintTask]?
}

private struct TaskDataWrapper: Decodable {
    let data: [SprintTask]?
}

private struct TaskDecodingError: LocalizedError {
    let responseSnippet: String

    var errorDescription: String? {
        "Tasks decode failed. Response: \(responseSnippet)"
    }
}

struct CreateTaskRequest: Encodable {
    let taskTitle: String
    let taskDesc: String
    let isSubtask: Bool
    let taskStatus: String
    let idCreator: Int
    let idResp: Int
    let projectId: Int
    let sprintId: Int

    enum CodingKeys: String, CodingKey {
        case taskTitle = "task_title"
        case taskDesc = "task_desc"
        case isSubtask = "is_subtask"
        case taskStatus = "task_status"
        case idCreator = "id_creator"
        case idResp = "id_resp"
        case projectId = "id_project_task"
        case sprintId = "id_sprint"
    }
}
