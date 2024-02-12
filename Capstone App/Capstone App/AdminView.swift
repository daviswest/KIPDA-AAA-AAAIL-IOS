import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct AdminView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var title = ""
    @State private var message = ""
    @State private var detail = ""
    @State private var date = Date()
    @State private var selectedType = NotificationType.weather
    @State private var selectedPriority = NotificationPriority.medium
    @State private var showSuccessMessage = false
    @State private var successMessage = ""

    init() {
        fetchNotifications()
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add New Notification").fontWeight(.bold)) {
                    TextField("Title", text: $title)
                    TextField("Message", text: $message)
                    TextField("Detailed Message", text: $detail)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Type", selection: $selectedType) {
                        ForEach(NotificationType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(NotificationPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    Button("Add Notification") {
                        addNotification()
                    }
                    if showSuccessMessage {
                        HStack{
                            Spacer()
                            Text(successMessage)
                                .font(.caption)
                                .foregroundColor(Color.green)
                                .padding(5)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(5)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        
                    }
                }
                
                Section(header: Text("Existing Notifications").fontWeight(.bold)) {
                    ForEach(notifications) { notification in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(notification.title).font(.headline)
                                Text(notification.message).font(.subheadline)
                            }
                            Spacer()
                            Text(notification.date, style: .date).font(.caption)
                        }
                    }
                    .onDelete(perform: deleteNotification)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Manage Notifications")
            .onAppear(perform: fetchNotifications)
            .scrollContentBackground(.hidden)
        }
    }

    private func addNotification() {
        let db = Firestore.firestore()
        db.collection("notifications").addDocument(data: [
            "title": title,
            "message": message,
            "detail": detail,
            "date": Timestamp(date: date),
            "type": selectedType.rawValue,
            "priority": selectedPriority.rawValue
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.successMessage = "Notification successfully added!"
                self.showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showSuccessMessage = false
                }
                self.resetFormFields()
                self.fetchNotifications()
            }
        }
    }
    
    private func resetFormFields() {
        title = ""
        message = ""
        detail = ""
        date = Date()
        selectedType = .weather
        selectedPriority = .medium
    }

    func fetchNotifications() {
        let db = Firestore.firestore()
        db.collection("notifications").order(by: "date", descending: true).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.notifications = querySnapshot!.documents.compactMap { document -> NotificationItem? in
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let message = data["message"] as? String ?? ""
                    let detail = data["detail"] as? String ?? ""
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let typeString = data["type"] as? String ?? NotificationType.weather.rawValue
                    let priorityString = data["priority"] as? String ?? NotificationPriority.low.rawValue
                    guard let type = NotificationType(rawValue: typeString),
                          let priority = NotificationPriority(rawValue: priorityString) else {
                        return nil
                    }
                    return NotificationItem(id: document.documentID, title: title, message: message, detail: detail, date: date, type: type, priority: priority)
                }
            }
        }
    }

    private func deleteNotification(at offsets: IndexSet) {
        let db = Firestore.firestore()
        
        offsets.forEach { index in
            if let id = notifications[index].id {
                db.collection("notifications").document(id).delete { error in
                    if let error = error {
                        print("Error deleting notification: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            notifications.remove(atOffsets: offsets)
                        }
                    }
                }
            }
        }
    }
}
