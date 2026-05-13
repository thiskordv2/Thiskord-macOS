import SwiftUI

struct EditChannelSheet: View {
    @Environment(\.dismiss) private var dismiss

    let channelName: String
    let channelDescription: String
    let onSave: (String, String) async -> Bool

    @State private var name: String
    @State private var description: String
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    init(
        channelName: String,
        channelDescription: String,
        onSave: @escaping (String, String) async -> Bool
    ) {
        self.channelName = channelName
        self.channelDescription = channelDescription
        self.onSave = onSave
        _name = State(initialValue: channelName)
        _description = State(initialValue: channelDescription)
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Edit channel")
                .font(.title2)

            TextField("Name", text: $name)
            TextField("Description", text: $description)

            if !errorMessage.isEmpty {
                Text(errorMessage)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Button("Save") { submit() }
                    .disabled(isSubmitting)
            }
        }
        .padding(20)
        .frame(minWidth: 360)
    }

    private func submit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errorMessage = "Channel name is required."
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
                errorMessage = "Failed to update channel."
            }
        }
    }
}

#Preview {
    EditChannelSheet(channelName: "general", channelDescription: "", onSave: { _, _ in true })
}
