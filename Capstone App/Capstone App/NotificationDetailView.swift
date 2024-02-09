import SwiftUI

struct NotificationDetailView: View {
    var notification: NotificationItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    notificationTypeIcon
                        .font(.largeTitle)
                    Spacer()
                    Text(notification.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(notification.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(notification.message)
                    .font(.body)
                
                priorityIndicator
            }
            .padding()
        }
        .navigationBarTitle("Notification Details", displayMode: .inline)
    }
    
    private var notificationTypeIcon: some View {
        switch notification.type {
        case .weather:
            return Image(systemName: "cloud.rain.fill")
        case .community:
            return Image(systemName: "building.2.fill")
        case .health:
            return Image(systemName: "cross.fill")
        }
    }
    
    private var priorityIndicator: some View {
        Text("Priority: \(priorityText)")
            .fontWeight(.semibold)
            .padding(8)
            .background(priorityColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private var priorityText: String {
        switch notification.priority {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        }
    }
    
    private var priorityColor: Color {
        switch notification.priority {
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
}

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(notification: NotificationItem(title: "Sample Notification", message: "This is a detailed view of the notification, providing more information to the user.", date: Date(), type: .community, priority: .high))
    }
}
