import SwiftUI

struct CreateSprintSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goal = ""
    @State private var beginDate = Date()
    @State private var endDate = Date()
    @State private var errorMessage = ""
    @State private var isSubmitting = false
    let onSubmit: (String, String, String) async -> Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Create Sprint")
                .font(.title2)

            TextField("Goal", text: $goal)

            DatePicker("Begin date", selection: $beginDate, displayedComponents: .date)
            DatePicker("End date", selection: $endDate, displayedComponents: .date)

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
        .frame(minWidth: 320)
    }

    private func submit() {
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedGoal.isEmpty {
            errorMessage = "Goal is required."
            return
        }

        let beginString = formattedDate(beginDate)
        let endString = formattedDate(endDate)

        isSubmitting = true
        errorMessage = ""
        Task {
            let ok = await onSubmit(trimmedGoal, beginString, endString)
            isSubmitting = false
            if ok {
                dismiss()
            } else {
                errorMessage = "Failed to create sprint."
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CreateSprintSheet { _, _, _ in true }
}
