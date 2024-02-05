import SwiftUI

struct NotificationRow: View {
    var item: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(item.message)
                .font(.subheadline)
            Text(item.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.message), \(item.date, style: .date)")
    }
}

struct HomeView: View {
    //Sample notifications for demonstration
    private let notifications = [
        NotificationItem(title: "Weather Alert", message: "Severe thunderstorm warning in your area. Take precautions.", date: Date()),
        NotificationItem(title: "Community Update", message: "Local community center closed today due to maintenance.", date: Date().addingTimeInterval(-86400)),
        NotificationItem(title: "Health Advisory", message: "Flu season is here. Consider getting vaccinated.", date: Date().addingTimeInterval(-172800))
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image("kipda_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.leading, 10)
                    
                    Spacer()
                }
                Divider()
                
                List(notifications) { item in
                    NavigationLink(destination: NotificationDetailView(notification: item)) {
                        NotificationRow(item: item)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Emergency Notifications", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
