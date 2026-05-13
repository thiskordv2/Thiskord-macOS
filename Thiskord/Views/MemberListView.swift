import SwiftUI

struct MemberListView: View {
    let users: [UserAccount]
    let onEditProject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Membres")
                .font(.headline)

            List(users, id: \.self) { user in
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.userName ?? "")
                    Text(user.userMail ?? "")
                }
            }

            HStack {
                Spacer()
                Menu("Edit") {
                    Button("Modifier le projet", action: onEditProject)
                }
            }
        }
        .padding(12)
    }
}
