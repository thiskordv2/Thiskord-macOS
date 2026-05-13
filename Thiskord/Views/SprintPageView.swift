import SwiftUI

struct SprintPageView: View {
    @EnvironmentObject private var session: SessionStore
    let sprint: Sprint
    let onClose: () -> Void
    let projectId: Int

    @StateObject private var viewModel = SprintPageViewModel()
    @State private var isCreateTaskPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sprint details")
                        .font(.title2)
                    Text("Title")
                        .font(.headline)
                    Text(sprint.sprintGoal)
                }
                Spacer()
                Button("Close", action: onClose)
            }

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start")
                        .font(.headline)
                    Text(sprint.sprintBeginDate)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("End")
                        .font(.headline)
                    Text(sprint.sprintEndDate)
                }
            }

            HStack {
                Spacer()
                Button("Add task") { isCreateTaskPresented = true }
            }

            Text("Sprint tasks")
                .font(.headline)

            if viewModel.isLoading {
                ProgressView()
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
            }

            List(viewModel.tasks, id: \.self) { task in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.taskTitle)
                        Text(task.taskDesc ?? "")
                        Text(task.taskStatus)
                    }
                    Spacer()
                    Button("Delete") {
                        Task {
                            await viewModel.deleteTask(
                                taskId: task.taskId,
                                sprintId: sprint.sprintId,
                                token: session.token
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
        .task(id: sprint.sprintId) {
            await viewModel.loadTasks(sprint: sprint, token: session.token)
        }
        .sheet(isPresented: $isCreateTaskPresented) {
            CreateTaskSheet { title, description, status in
                await viewModel.createTask(
                    title: title,
                    description: description,
                    status: status,
                    sprintId: sprint.sprintId,
                    projectId: projectId,
                    creatorId: session.currentUserId ?? 0,
                    token: session.token
                )
            }
        }
    }
}

#Preview {
    SprintPageView(
        sprint: Sprint(
            sprintId: 1,
            sprintGoal: "Sprint 1",
            sprintBeginDate: "2026-01-01",
            sprintEndDate: "2026-01-10",
            projectId: 1
        ),
        onClose: {},
        projectId: 1
    )
    .environmentObject(SessionStore())
}
