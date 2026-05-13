import SwiftUI

struct ProjectSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let projectName: String
    let projectDescription: String
    let onSave: (String, String) async -> Bool
    let onDelete: () async -> Bool

    @State private var name: String
    @State private var description: String
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    @State private var isConfirmDeletePresented = false

    init(
        projectName: String,
        projectDescription: String,
        onSave: @escaping (String, String) async -> Bool,
        onDelete: @escaping () async -> Bool
    ) {
        self.projectName = projectName
        self.projectDescription = projectDescription
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: projectName)
        _description = State(initialValue: projectDescription)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project settings")
                .font(.title2)

            TextField("Project name", text: $name)
            TextField("Description", text: $description)

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Save") { submit() }
                    .disabled(isSubmitting)
                Spacer()
                Button("Delete") { isConfirmDeletePresented = true }
                    .disabled(isSubmitting)
            }
        }
        .padding(20)
        .frame(minWidth: 420)
        .alert("Confirm deletion", isPresented: $isConfirmDeletePresented) {
            Button("Delete", role: .destructive) { deleteProject() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Delete this project permanently?")
        }
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
            let ok = await onSave(trimmedName, description.trimmingCharacters(in: .whitespacesAndNewlines))
            isSubmitting = false
            if ok {
                dismiss()
            } else {
                errorMessage = "Failed to update project."
            }
        }
    }

    private func deleteProject() {
        isSubmitting = true
        errorMessage = ""
        Task {
            let ok = await onDelete()
            isSubmitting = false
            if ok {
                dismiss()
            } else {
                errorMessage = "Failed to delete project."
            }
        }
    }
 }

 #Preview {
     ProjectSettingsSheet(
         projectName: "Thiskord",
         projectDescription: "Project description",
         onSave: { _, _ in true },
         onDelete: { true }
     )
 }
