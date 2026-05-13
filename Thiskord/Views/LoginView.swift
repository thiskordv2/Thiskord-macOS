import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 25) {
            Text("Login")
                .font(.title)

            TextField("Username", text: $username)
                .disabled(isLoading).glassEffect()

            SecureField("Password", text: $password)
                .disabled(isLoading).glassEffect()

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            Button {
                Task { await login() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .disabled(isLoading).glassEffect(.regular.tint(.blue).interactive())
        }
        .padding(16)
    }

    @MainActor
    private func login() async {
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUser.isEmpty, !trimmedPass.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = ""
        do {
            let response = try await AuthService().login(username: trimmedUser, password: trimmedPass)
            session.login(user: response.user, token: response.token)
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    LoginView()
        .environmentObject(SessionStore())
}
