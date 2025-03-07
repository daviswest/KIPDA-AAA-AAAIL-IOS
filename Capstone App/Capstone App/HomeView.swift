import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Combine

struct HomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var notifications: [NotificationItem] = []
    @State private var hiddenNotificationIds: Set<String> = []

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image("kipda_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                Divider()
                
                List {
                    ForEach(notifications) { item in
                        NavigationLink(destination: NotificationDetailView(notification: item)) {
                            NotificationRow(item: item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    print("View appeared. isAuthenticated: \(authManager.isAuthenticated), isGuest: \(authManager.isGuest)")
                        if authManager.isAuthenticated || authManager.isGuest {
                            fetchNotifications()
                        }
                                if authManager.isAuthenticated || authManager.isGuest {
                                    fetchNotifications()
                                }
                            }
                            .onReceive(authManager.$isAuthenticated) { isAuthenticated in
                                if isAuthenticated {
                                    fetchNotifications()
                                }
                            }
                            .onReceive(authManager.$isGuest) { isGuest in
                                if isGuest {
                                    fetchNotifications()
                                }
                            }


            }
            .navigationBarHidden(true)
        }
    }

    func fetchNotifications() {
        let db = Firestore.firestore()

        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No user or guest is logged in")
            return
        }

        let userRef = db.collection("users").document(currentUserID)

        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                let userData = document.data() ?? [:]
                let userCounty = userData["county"] as? String ?? ""

                if let hiddenIds = userData["hiddenNotifications"] as? [String] {
                    self.hiddenNotificationIds = Set(hiddenIds)
                } else {

                    userRef.setData(["hiddenNotifications": []], merge: true) { error in
                        if let error = error {
                            print("Error initializing hiddenNotifications: \(error.localizedDescription)")
                        } else {
                            print("hiddenNotifications initialized successfully.")
                        }
                    }
                    self.hiddenNotificationIds = Set()
                }

                self.fetchAndFilterNotifications(userCounty: userCounty)
            } else {
                print("User document does not exist or is missing required fields.")
            }
        }
    }

    private func fetchAndFilterNotifications(userCounty: String) {
        let db = Firestore.firestore()
        db.collection("notifications").order(by: "date", descending: true).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                self.notifications = documents.compactMap { document -> NotificationItem? in
                    let notificationId = document.documentID
                    if self.hiddenNotificationIds.contains(notificationId) {
                        return nil
                    }
                    
                    guard let selectedCounties = document.data()["selectedCounties"] as? [String], selectedCounties.contains(userCounty) else {
                        return nil
                    }
                    
                    return self.mapDocumentToNotificationItem(document: document)
                }
            } else {
                print("No notifications fetched.")
            }
        }
    }



    private func mapDocumentToNotificationItem(document: QueryDocumentSnapshot) -> NotificationItem? {
        let data = document.data()
        let title = data["title"] as? String ?? ""
        let message = data["message"] as? String ?? ""
        let detail = data["detail"] as? String ?? ""
        let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
        let typeString = data["type"] as? String ?? ""
        let priorityString = data["priority"] as? String ?? ""

        
        guard let type = NotificationType(rawValue: typeString),
              let priority = NotificationPriority(rawValue: priorityString) else {
            print("Failed to map notification due to type or priority mismatch. Type: \(typeString), Priority: \(priorityString)")
            return nil
        }
        
        return NotificationItem(id: document.documentID, title: title, message: message, detail: detail, date: date, type: type, priority: priority)
    }





    func deleteItems(at offsets: IndexSet) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }

        let idsToDelete = offsets.compactMap { notifications[$0].id }
        notifications.remove(atOffsets: offsets)

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        for id in idsToDelete {
            userRef.updateData([
                "hiddenNotifications": FieldValue.arrayUnion([id])
            ]) { error in
                if let error = error {
                    print("Error updating hidden notifications: \(error.localizedDescription)")
                } else {
                }
            }
        }
    }
}

struct NotificationRow: View {
    var item: NotificationItem
    
    private var icon: Image {
        switch item.type {
        case .weather:
            return Image(systemName: "cloud.rain.fill")
        case .service:
            return Image(systemName: "megaphone.fill")
        case .closure:
            return Image(systemName: "nosign")
        case .event:
            return Image(systemName: "calendar")
        case .health:
            return Image(systemName: "cross.fill")
        }
    }
    
    private var priorityIndicator: some View {
        Group {
            switch item.priority {
            case .high:
                Text("!")
                    .font(.headline)
                    .foregroundColor(.red)
            case .medium:
                Text("!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            case .low:
                EmptyView()
            }
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            icon
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                    priorityIndicator
                }
                
                Text(item.message)
                    .font(.subheadline)
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
