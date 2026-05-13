import SwiftUI

struct CreateProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    let onSubmit: (String, String) async -> Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Create Project")
                .font(.title2)

            TextField("Name", text: $name)
            TextField("Description", text: $description)

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Create") { submit() }
                    .disabled(isSubmitting)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }

    private func submit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Project name is required."
            return
        }

        isSubmitting = true
        errorMessage = ""
        Task {
            let ok = await onSubmit(trimmedName, description.trimmingCharacters(in: .whitespacesAndNewlines))
            isSubmitting = false
            if ok {
                dismiss()
            } else {
                errorMessage = "Failed to create project."
            }
        }
    }
}

#Preview {
    CreateProjectSheet { _, _ in true }
}
