import Foundation
import Combine

@MainActor
final class NavigatorViewModel: ObservableObject {
    @Published private(set) var projects: [Project] = []
    @Published private(set) var channels: [Channel] = []
    @Published private(set) var users: [UserAccount] = []
    @Published private(set) var sprints: [Sprint] = []
    @Published var selectedProject: Project?
    @Published var selectedChannel: Channel?
    @Published var selectedSprint: Sprint?
    @Published var isLoadingProjects = false
    @Published var errorMessage: String = ""

    private let projectService = ProjectService()
    private let channelService = ChannelService()
    private let userService = UserService()
    private let sprintService = SprintService()

    func loadProjects(token: String) async {
        guard projects.isEmpty else { return }
        isLoadingProjects = true
        errorMessage = ""
        defer { isLoadingProjects = false }

        do {
            let result = try await projectService.getAllProjects(token: token)
            projects = result
            if selectedProject == nil {
                selectedProject = projects.first
            }
            if let selectedProject {
                await selectProject(selectedProject, token: token)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectProject(_ project: Project?, token: String) async {
        guard let project else {
            channels = []
            users = []
            sprints = []
            selectedChannel = nil
            selectedSprint = nil
            return
        }

        selectedProject = project
        selectedChannel = nil
        selectedSprint = nil
        errorMessage = ""

        do {
            channels = try await channelService.getChannels(projectId: project.id, token: token)
            if selectedChannel == nil {
                selectedChannel = channels.first
            }
        } catch {
            channels = []
            if shouldReport(error) { errorMessage = error.localizedDescription }
        }

        do {
            users = try await userService.getUsers(projectId: project.id, token: token)
        } catch {
            users = []
            if shouldReport(error), errorMessage.isEmpty { errorMessage = error.localizedDescription }
        }

        do {
            sprints = try await sprintService.getSprints(projectId: project.id, token: token)
        } catch {
            sprints = []
            if shouldReport(error), errorMessage.isEmpty { errorMessage = error.localizedDescription }
        }
    }

    private func shouldReport(_ error: Error) -> Bool {
        if case ApiError.httpError(let statusCode, _) = error, statusCode == 404 {
            return false
        }
        return true
    }

    func createChannel(
        name: String,
        description: String,
        token: String
    ) async -> Bool {
        guard let project = selectedProject else { return false }
        do {
            try await channelService.createChannel(
                name: name,
                description: description,
                projectId: project.id,
                token: token
            )
            channels = try await channelService.getChannels(projectId: project.id, token: token)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateChannel(
        channel: Channel,
        name: String,
        description: String,
        token: String
    ) async -> Bool {
        guard let channelId = channel.id, let project = selectedProject else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Channel name is required."
            return false
        }

        do {
            try await channelService.updateChannel(
                channelId: channelId,
                name: trimmedName,
                description: description,
                token: token
            )
            channels = try await channelService.getChannels(projectId: project.id, token: token)
            if let selectedChannel, selectedChannel.id == channelId {
                self.selectedChannel = channels.first(where: { $0.id == channelId })
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteChannel(
        channel: Channel,
        token: String
    ) async -> Bool {
        guard let channelId = channel.id, let project = selectedProject else { return false }
        do {
            try await channelService.deleteChannel(channelId: channelId, token: token)
            channels = try await channelService.getChannels(projectId: project.id, token: token)
            if selectedChannel?.id == channelId {
                selectedChannel = channels.first
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func createSprint(
        goal: String,
        beginDate: String,
        endDate: String,
        token: String
    ) async -> Bool {
        guard let project = selectedProject else { return false }
        do {
            try await sprintService.createSprint(
                projectId: project.id,
                goal: goal,
                beginDate: beginDate,
                endDate: endDate,
                token: token
            )
            sprints = try await sprintService.getSprints(projectId: project.id, token: token)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func createProject(name: String, description: String, token: String) async -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Project name is required."
            return false
        }

        do {
            try await projectService.createProject(
                name: trimmedName,
                description: description,
                token: token
            )
            let result = try await projectService.getAllProjects(token: token)
            projects = result
            if let created = projects.first(where: { $0.name == trimmedName }) {
                await selectProject(created, token: token)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateProject(name: String, description: String, token: String) async -> Bool {
        guard let project = selectedProject else { return false }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Project name is required."
            return false
        }

        do {
            try await projectService.updateProject(
                projectId: project.id,
                name: trimmedName,
                description: description,
                token: token
            )
            let updated = Project(id: project.id, name: trimmedName, description: description)
            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = updated
            }
            await selectProject(updated, token: token)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteSelectedProject(token: String) async -> Bool {
        guard let project = selectedProject else { return false }
        do {
            try await projectService.deleteProject(projectId: project.id, token: token)
            let refreshed = try await projectService.getAllProjects(token: token)
            projects = refreshed
            selectedProject = projects.first
            if let selectedProject {
                await selectProject(selectedProject, token: token)
            } else {
                channels = []
                users = []
                sprints = []
                selectedChannel = nil
                selectedSprint = nil
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func generateInvite(expiresAt: Date, token: String) async -> String? {
        guard let project = selectedProject else {
            errorMessage = "Select a project first."
            return nil
        }

        let formatted = formatInviteDate(expiresAt)
        do {
            return try await projectService.inviteToProject(
                projectId: project.id,
                expiresAt: formatted,
                token: token
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func joinProject(inviteUrl: String, token: String) async -> String? {
        let trimmed = inviteUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else {
            return "L'URL fournie est invalide."
        }

        let tokenValue = url.pathComponents.last ?? ""
        if tokenValue.isEmpty {
            return "L'URL fournie est invalide."
        }

        do {
            let result = try await projectService.joinProject(token: tokenValue, authToken: token)
            let projects = try await projectService.getAllProjects(token: token)
            self.projects = projects
            return result
        } catch {
            return error.localizedDescription
        }
    }

    private func formatInviteDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter.string(from: date)
    }
}
