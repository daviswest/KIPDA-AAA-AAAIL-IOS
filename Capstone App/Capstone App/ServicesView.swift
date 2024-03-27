import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ServiceItem: Identifiable {
    let id: String
    let title: String
    let type: String
    let description: String
    let url: String
}

struct ServiceRow: View {
    var item: ServiceItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            Text(item.type)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}


struct ServicesView: View {
    @State private var services: [ServiceItem] = []

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
                    ForEach(services) { item in
                        NavigationLink(destination: ServiceDetailView(service: item)) {
                            ServiceRow(item: item)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarHidden(true)
                .onAppear {
                    fetchServices()
                }
            }
        }
    }

    func fetchServices() {
        let db = Firestore.firestore()
        
        db.collection("resources").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.services = querySnapshot!.documents.compactMap { document -> ServiceItem? in
                    let id = document.documentID
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let url = data["url"] as? String ?? ""
                    return ServiceItem(id: id, title: title, type: type, description: description, url: url)
                }
            }
        }
    }
}
