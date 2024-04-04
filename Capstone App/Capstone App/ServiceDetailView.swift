import SwiftUI
import Firebase

struct ServiceDetailView: View {
    var service: ServiceItem
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(service.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Text(service.description)
                    .font(.body)
                
                Link("Learn More", destination: URL(string: service.url)!)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .navigationBarTitle("Service Details", displayMode: .inline)
    }
}
