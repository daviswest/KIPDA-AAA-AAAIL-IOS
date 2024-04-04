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
        @State private var selectedCounties = Set<String>() // Updated to handle multiple counties
        @State private var selectedZipCodes = Set<String>()
        @State private var showSuccessMessage = false
        @State private var successMessage = ""
        @State private var showErrorMessage = false
        @State private var errorMessage = ""
        @State private var showingLocationSelector = false
    
    // Dictionary holding counties and their zip codes
    let countiesWithZipCodes: [String: [String]] = [
        "Jefferson": [
            "40018", "40023", "40025", "40027", "40041", "40059", "40067", "40071",
            "40077", "40118", "40129", "40150", "40165", "40201", "40202", "40203",
            "40204", "40205", "40206", "40207", "40208", "40209", "40210", "40211",
            "40212", "40213", "40214", "40215", "40216", "40217", "40218", "40219",
            "40220", "40221", "40222", "40223", "40224", "40225", "40228", "40229",
            "40231", "40232", "40233", "40241", "40242", "40243", "40245", "40250",
            "40251", "40252", "40253", "40255", "40256", "40257", "40258", "40259",
            "40261", "40266", "40268", "40269", "40270", "40272", "40280", "40281",
            "40282", "40283", "40285", "40287", "40289", "40290", "40291", "40292",
            "40293", "40294", "40295", "40296", "40297", "40298", "40299"
        ],
        "Bullitt" : ["40444"],
        "Shelby" : ["40444"],
        "Spencer" : ["40444"],
        "Oldham" : ["40444"],
        "Henry" : ["40444"],
        "Trimble" : ["40444"],
    ]
    
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
                    Button("Select Recipients") {
                                            showingLocationSelector = true
                                        }
                                        .sheet(isPresented: $showingLocationSelector) {
                                            CountyAndZipCodeSelector(selectedCounties: $selectedCounties, selectedZipCodes: $selectedZipCodes, countiesWithZipCodes: countiesWithZipCodes)
                                        }
                                        
                    // Assuming this is within your body definition in AdminView

                    // After defining your body view or within the view where you intend to display selected zip codes
                    let allZipCodesForSelectedCounties: Set<String> = Set(selectedCounties.flatMap { countiesWithZipCodes[$0, default: []] })

                    // This flag determines if all zip codes in the selected counties have indeed been selected
                    let areAllZipCodesSelected = !selectedZipCodes.isEmpty && selectedZipCodes == allZipCodesForSelectedCounties

                    if selectedZipCodes.isEmpty {

                    } else if areAllZipCodesSelected {
                        Text("To: All users in \(selectedCounties.joined(separator: ", ")) county")
                            .font(.headline)
                            .padding(.top)
                    } else {
                        Text("To: \(selectedZipCodes.joined(separator: ", "))")
                            .font(.headline)
                            .padding(.top)
                    }


                    Button(action: {
                        addNotification()
                    }) {
                        Text("Send")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.top) // Add some space above the button if needed

                    if showSuccessMessage {
                        HStack {
                            Spacer()
                            Text(successMessage)
                                .font(.caption)
                                .foregroundColor(Color.green)
                                .padding(5)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(5)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                    } else if showErrorMessage {
                        HStack {
                            Spacer()
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(Color.red)
                                .padding(5)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(5)
                            Spacer()
                        }
                        .padding(.bottom, 10)
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
        
        // Check if no counties or zip codes are selected
        if selectedZipCodes.isEmpty {
            self.errorMessage = "Error: Please select at least one recipient."
                self.showErrorMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showErrorMessage = false
                }
                return
        }

        var documentData: [String: Any] = [
            "title": title,
            "message": message,
            "detail": detail,
            "date": Timestamp(date: date),
            "type": selectedType.rawValue,
            "priority": selectedPriority.rawValue
        ]
        
        var allZipCodesForSelectedCounties = Set<String>()
        for county in selectedCounties {
            if let zipCodes = countiesWithZipCodes[county] {
                allZipCodesForSelectedCounties.formUnion(zipCodes)
            }
        }
        
        if selectedZipCodes == allZipCodesForSelectedCounties && !selectedCounties.isEmpty {
            documentData["targetCounties"] = Array(selectedCounties)
            documentData["allZipCodesInSelectedCounties"] = true
        } else if !selectedZipCodes.isEmpty {
            documentData["targetZipCodes"] = Array(selectedZipCodes)
            documentData["allZipCodesInSelectedCounties"] = false
        }
        
        db.collection("notifications").addDocument(data: documentData) { err in
            if let err = err {
                self.successMessage = "Error adding document: \(err.localizedDescription)"
                self.showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showSuccessMessage = false
                }
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
        selectedZipCodes = []
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

struct ZipCodeSelector: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedZipCodes: Set<String>
    let allZipCodes: [String]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 20) {
                    ForEach(allZipCodes, id: \.self) { zipCode in
                        ZipCodeButton(zipCode: zipCode, isSelected: selectedZipCodes.contains(zipCode)) {
                            if selectedZipCodes.contains(zipCode) {
                                selectedZipCodes.remove(zipCode)
                            } else {
                                selectedZipCodes.insert(zipCode)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Zip Codes")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ZipCodeButton: View {
    let zipCode: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
                    Text(zipCode)
                        .font(.caption) // Adjust font size here
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity) // Ensure button uses available space
                        .foregroundColor(isSelected ? .white : .black)
                        .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
    }
}
