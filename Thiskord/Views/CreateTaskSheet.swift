import SwiftUI

struct CreateTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var status = "IN_PROGRESS"
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    let onSubmit: (String, String, String) async -> Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Create Task")
                .font(.title2)

            TextField("Title", text: $title)
            TextField("Description", text: $description)

            Picker("Status", selection: $status) {
                Text("IN_PROGRESS").tag("IN_PROGRESS")
                Text("TODO").tag("TODO")
                Text("DONE").tag("DONE")
            }

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
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errorMessage = "Title is required."
            return
        }

        isSubmitting = true
        errorMessage = ""
        Task {
            let ok = await onSubmit(trimmedTitle, description.trimmingCharacters(in: .whitespacesAndNewlines), status)
            isSubmitting = false
            if ok {
                dismiss()
            } else {
                errorMessage = "Failed to create task."
            }
        }
    }
}

#Preview {
    CreateTaskSheet { _, _, _ in true }
}
