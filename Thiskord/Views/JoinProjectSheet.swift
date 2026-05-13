import SwiftUI

struct JoinProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""
    @State private var message = ""
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    let onJoin: (String) async -> String?

    var body: some View {
        VStack(spacing: 12) {
            Text("Join a project")
                .font(.title2)

            TextField("Invitation URL", text: $url)

            if !message.isEmpty {
                Text(message)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Join") { join() }
                    .disabled(isSubmitting)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }

    private func join() {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = "Invitation URL is required."
            return
        }

        isSubmitting = true
        errorMessage = ""
        Task {
            let result = await onJoin(trimmed)
            isSubmitting = false
            if let result {
                message = result
                dismiss()
            } else {
                errorMessage = "Unable to join project."
            }
        }
    }
}

#Preview {
    JoinProjectSheet { _ in "Joined" }
}
