import SwiftUI

struct NotificationItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String
    var date: Date
    var type: NotificationType
    var priority: NotificationPriority
}

enum NotificationType {
    case weather, community, health
}

enum NotificationPriority {
    case high, medium, low
}

struct NotificationRow: View {
    var item: NotificationItem
    
    private var icon: Image {
        switch item.type {
        case .weather:
            return Image(systemName: "cloud.rain.fill")
        case .community:
            return Image(systemName: "building.2.fill")
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
                        .accessibilityAddTraits(.isHeader)
                    priorityIndicator
                }
                
                Text(item.message)
                    .font(.subheadline)
                Text(item.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.message), \(item.date, style: .date)")
    }
}

struct HomeView: View {
    private let notifications = [
        NotificationItem(title: "Weather Alert", message: "Severe thunderstorm warning in your area. Take precautions.", date: Date(), type: .weather, priority: .high),
        NotificationItem(title: "Community Update", message: "Local community center closed today due to maintenance.", date: Date().addingTimeInterval(-86400), type: .community, priority: .medium),
        NotificationItem(title: "Health Advisory", message: "Flu season is here. Consider getting vaccinated.", date: Date().addingTimeInterval(-172800), type: .health, priority: .low)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image("kipda_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .padding(.leading, 10)
                        .padding(.top, 0)
                        .padding(.bottom, 0)

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

