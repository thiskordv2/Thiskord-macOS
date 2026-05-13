import SwiftUI

struct ServerDropdownView: View {
    @ObservedObject var viewModel: NavigatorViewModel
    @EnvironmentObject private var session: SessionStore
    let onCreateChannel: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Picker("Mes serveurs", selection: $viewModel.selectedProject) {
                ForEach(viewModel.projects, id: \.self) { project in
                    Text(project.name).tag(Optional(project))
                }
            }
            .pickerStyle(.menu)
            .onChange(of: viewModel.selectedProject) { _, newValue in
                Task { await viewModel.selectProject(newValue, token: session.token) }
            }

            Button("+ Channel", action: onCreateChannel)
        }
    }
}
