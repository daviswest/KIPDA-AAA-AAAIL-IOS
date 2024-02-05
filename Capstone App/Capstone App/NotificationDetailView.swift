import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    var title: String
    var message: String
    var date: Date
}

struct NotificationDetailView: View {
    var notification: NotificationItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(notification.title)
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
                Text(notification.message)
                    .font(.body)
                Text(notification.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Notification Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
