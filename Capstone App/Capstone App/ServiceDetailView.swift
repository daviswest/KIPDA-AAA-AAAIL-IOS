import SwiftUI
import Firebase

struct ServiceDetailView: View {
    var service: ServiceItem
    @Environment(\.presentationMode) var presentationMode

    private var serviceIcon: some View {
        Image(systemName: "gearshape.fill").resizable()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(service.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    serviceIcon
                        .frame(width: 30, height: 30)
                        .foregroundColor(.secondary)
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
