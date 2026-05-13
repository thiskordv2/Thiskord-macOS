import SwiftUI

struct SprintListView: View {
    let sprints: [Sprint]
    let selectedSprint: Sprint?
    let onCreateSprint: () -> Void
    let onSelectSprint: (Sprint) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Menu(selectedSprint?.sprintGoal ?? "Sprints") {
                ForEach(sprints, id: \.self) { sprint in
                    Button(sprint.sprintGoal) { onSelectSprint(sprint) }
                }
            }

            Button("+", action: onCreateSprint)
                .frame(width: 32, height: 32)
        }
    }
}
