import SwiftUI

struct ProfileMenuView: View {
    @EnvironmentObject private var session: SessionStore
    let onCreateProject: () -> Void
    let onInviteProject: () -> Void
    let onJoinProject: () -> Void

    var body: some View {
        HStack {
            Menu {
                Button("Creer un projet", action: onCreateProject)
                Button("Inviter dans le projet", action: onInviteProject)
                Button("Rejoindre un projet", action: onJoinProject)
                Button("Se deconnecter") { session.logout() }
            } label: {
                Circle()
                    .frame(width: 50, height: 50)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            Spacer()
        }
    }
}
