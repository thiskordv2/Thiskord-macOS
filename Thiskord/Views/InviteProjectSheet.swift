import SwiftUI

struct InviteProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expiresAt = Date()
    @State private var generatedToken = ""
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    let onGenerate: (Date) async -> String?

    var body: some View {
        VStack(spacing: 12) {
            Text("Create invitation")
                .font(.title2)

            DatePicker("Expiration date", selection: $expiresAt, displayedComponents: .date)

            if !generatedToken.isEmpty {
                Text(generatedToken)
                Button("Copy") { copyToClipboard(generatedToken) }
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            HStack {
                Button("Close") { dismiss() }
                Button("Generate") { generate() }
                    .disabled(isSubmitting)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }

    private func generate() {
        isSubmitting = true
        errorMessage = ""
        Task {
            let token = await onGenerate(expiresAt)
            isSubmitting = false
            if let token {
                generatedToken = token
                copyToClipboard(token)
            } else {
                errorMessage = "Unable to generate invitation."
            }
        }
    }

    private func copyToClipboard(_ value: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        #endif
    }
}

#Preview {
    InviteProjectSheet { _ in "https://example.com/invite/token" }
}
