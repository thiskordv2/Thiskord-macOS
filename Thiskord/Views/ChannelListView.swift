import SwiftUI

struct ChannelListView: View {
    let channels: [Channel]
    @Binding var selectedChannel: Channel?
    let onEdit: (Channel) -> Void
    let onDelete: (Channel) -> Void

    var body: some View {
        List(channels, id: \.self, selection: $selectedChannel) { channel in
            Text(channel.displayName)
                .contextMenu {
                    Button("Modifier") { onEdit(channel) }
                    Button("Supprimer") { onDelete(channel) }
                }
        }
    }
}
