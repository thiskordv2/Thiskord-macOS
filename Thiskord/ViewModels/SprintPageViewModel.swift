import Foundation
import Combine

@MainActor
final class SprintPageViewModel: ObservableObject {
    @Published private(set) var tasks: [SprintTask] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let taskService = TaskService()

    func createTask(
        title: String,
        description: String,
        status: String,
        sprintId: Int,
        projectId: Int,
        creatorId: Int,
        token: String
    ) async -> Bool {
        errorMessage = ""
        let request = CreateTaskRequest(
            taskTitle: title,
            taskDesc: description,
            isSubtask: false,
            taskStatus: status,
            idCreator: creatorId,
            idResp: creatorId,
            projectId: projectId,
            sprintId: sprintId
        )

        do {
            try await taskService.createTask(request, token: token)
            tasks = try await taskService.getTasksBySprint(sprintId: sprintId, token: token)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func loadTasks(sprint: Sprint, token: String) async {
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            tasks = try await taskService.getTasksBySprint(sprintId: sprint.sprintId, token: token)
        } catch {
            tasks = []
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(taskId: Int, sprintId: Int, token: String) async {
        errorMessage = ""
        do {
            try await taskService.deleteTask(taskId: taskId, token: token)
            tasks = try await taskService.getTasksBySprint(sprintId: sprintId, token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
