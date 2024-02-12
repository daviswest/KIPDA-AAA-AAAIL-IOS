import SwiftUI
import Firebase

struct NotificationDetailView: View {
    var notification: NotificationItem
    @Environment(\.presentationMode) var presentationMode

    private var notificationTypeIcon: some View {
        switch notification.type {
        case .weather:
            return Image(systemName: "cloud.rain.fill").resizable()
        case .community:
            return Image(systemName: "building.2.fill").resizable()
        case .health:
            return Image(systemName: "cross.fill").resizable()
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(notification.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    notificationTypeIcon
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                }
                
                HStack {
                    priorityIndicator
                    Spacer()
                    Text(notification.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(notification.message)
            }
            .padding()
        }
        .navigationBarTitle("Notification Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            guard let notificationId = notification.id else {
                print("Notification ID is nil")
                return
            }
            hideNotificationForUser(notificationId: notificationId)
        }) {
            Image(systemName: "trash")
                .imageScale(.large)
                .foregroundColor(.red)
        })
    }

    private func hideNotificationForUser(notificationId: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        userRef.updateData([
            "hiddenNotifications": FieldValue.arrayUnion([notificationId])
        ]) { error in
            if let error = error {
                print("Error hiding notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully hidden for user")
                withAnimation {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
