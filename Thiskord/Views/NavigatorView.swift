import SwiftUI

struct NavigatorView: View {
    @EnvironmentObject private var session: SessionStore
    @StateObject private var viewModel = NavigatorViewModel()
    @State private var isProjectSettingsPresented = false
    @State private var isInviteProjectPresented = false

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(viewModel: viewModel)
                .frame(width: 200)

            Divider()
                .frame(width: 1)
                .background(Color.white.opacity(0.2))

            CenterPanelView(viewModel: viewModel)
                .frame(minWidth: 420, maxWidth: .infinity)

            if viewModel.selectedProject != nil {
                Divider()
                    .frame(width: 1)
                    .background(Color.white.opacity(0.2))

                MemberListView(
                    users: viewModel.users,
                    onEditProject: { isProjectSettingsPresented = true }
                )
                    .frame(width: 300)
            }
        }
        .task(id: session.token) {
            Task {
                await viewModel.loadProjects(token: session.token)
            }
        }
        .sheet(isPresented: $isProjectSettingsPresented) {
            if let project = viewModel.selectedProject {
                ProjectSettingsSheet(
                    projectName: project.name,
                    projectDescription: project.description,
                    onSave: { name, description in
                        await viewModel.updateProject(
                            name: name,
                            description: description,
                            token: session.token
                        )
                    },
                    onDelete: {
                        await viewModel.deleteSelectedProject(token: session.token)
                    }
                )
            }
        }
        .sheet(isPresented: $isInviteProjectPresented) {
            InviteProjectSheet { expiresAt in
                await viewModel.generateInvite(expiresAt: expiresAt, token: session.token)
            }
        }
    }
}

private struct SidebarView: View {
    @ObservedObject var viewModel: NavigatorViewModel
    @EnvironmentObject private var session: SessionStore
    @State private var isCreateChannelPresented = false
    @State private var isCreateSprintPresented = false
    @State private var isCreateProjectPresented = false
    @State private var isInviteProjectPresented = false
    @State private var isJoinProjectPresented = false
    @State private var editingChannel: ChannelSelection?
    @State private var deletingChannel: Channel?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ServerDropdownView(
                viewModel: viewModel,
                onCreateChannel: { isCreateChannelPresented = true }
            )
            .padding(12)

            Divider()
                .frame(height: 1)
                .background(Color.white.opacity(0.2))

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.caption)
                    .padding(12)
            }

            ChannelListView(
                channels: viewModel.channels,
                selectedChannel: $viewModel.selectedChannel,
                onEdit: {
                    editingChannel = ChannelSelection(channel: $0)
                },
                onDelete: { deletingChannel = $0 }
            )
            .padding(.vertical, 8)

            Divider()
                .frame(height: 1)
                .background(Color.white.opacity(0.2))

            SprintListView(
                sprints: viewModel.sprints,
                selectedSprint: viewModel.selectedSprint,
                onCreateSprint: { isCreateSprintPresented = true },
                onSelectSprint: { viewModel.selectedSprint = $0 }
            )
            .padding(12)

            Divider()
                .frame(height: 1)
                .background(Color.white.opacity(0.2))

            Spacer()

            ProfileMenuView(
                onCreateProject: { isCreateProjectPresented = true },
                onInviteProject: { isInviteProjectPresented = true },
                onJoinProject: { isJoinProjectPresented = true }
            )
            .padding(12)
        }
        .sheet(isPresented: $isCreateChannelPresented) {
            CreateChannelSheet { name, description in
                await viewModel.createChannel(
                    name: name,
                    description: description,
                    token: session.token
                )
            }
        }
        .sheet(isPresented: $isCreateSprintPresented) {
            CreateSprintSheet { goal, beginDate, endDate in
                await viewModel.createSprint(
                    goal: goal,
                    beginDate: beginDate,
                    endDate: endDate,
                    token: session.token
                )
            }
        }
        .sheet(isPresented: $isCreateProjectPresented) {
            CreateProjectSheet { name, description in
                await viewModel.createProject(
                    name: name,
                    description: description,
                    token: session.token
                )
            }
        }
        .sheet(isPresented: $isInviteProjectPresented) {
            InviteProjectSheet { expiresAt in
                await viewModel.generateInvite(expiresAt: expiresAt, token: session.token)
            }
        }
        .sheet(isPresented: $isJoinProjectPresented) {
            JoinProjectSheet { inviteUrl in
                await viewModel.joinProject(inviteUrl: inviteUrl, token: session.token)
            }
        }
        .sheet(item: $editingChannel) { selection in
            EditChannelSheet(
                channelName: selection.channel.name,
                channelDescription: selection.channel.description ?? "",
                onSave: { name, description in
                    await viewModel.updateChannel(
                        channel: selection.channel,
                        name: name,
                        description: description,
                        token: session.token
                    )
                }
            )
        }
        .alert(
            "Supprimer le channel",
            isPresented: Binding(
                get: { deletingChannel != nil },
                set: { if !$0 { deletingChannel = nil } }
            )
        ) {
            Button("Supprimer", role: .destructive) {
                if let deletingChannel {
                    Task {
                        _ = await viewModel.deleteChannel(channel: deletingChannel, token: session.token)
                        self.deletingChannel = nil
                    }
                }
            }
            Button("Annuler", role: .cancel) { deletingChannel = nil }
        } message: {
            Text("Voulez-vous supprimer ce channel ?")
        }
    }
}

private struct ChannelSelection: Identifiable {
    let id = UUID()
    let channel: Channel
}

private struct CenterPanelView: View {
    @ObservedObject var viewModel: NavigatorViewModel

    var body: some View {
        VStack(spacing: 0) {
            ProjectTitleView(title: viewModel.selectedProject?.name ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            Divider()

            if let sprint = viewModel.selectedSprint {
                SprintPageView(
                    sprint: sprint,
                    onClose: { viewModel.selectedSprint = nil },
                    projectId: viewModel.selectedProject?.id ?? 0
                )
            } else {
                ChatView(selectedChannel: viewModel.selectedChannel)
            }
        }
    }
}

private struct ProjectTitleView: View {
    let title: String

    var body: some View {
        Text(title.isEmpty ? "Projet" : title)
            .font(.title2)
    }
}

#Preview {
    NavigatorView()
        .environmentObject(SessionStore())
}
