import Foundation
import FirebaseFirestoreSwift

struct NotificationItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var message: String
    var detail: String
    var date: Date
    var type: NotificationType
    var priority: NotificationPriority
}

enum NotificationType: String, Codable, CaseIterable {
    case weather = "Weather"
    case community = "Community"
    case health = "Health"
}

enum NotificationPriority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}
