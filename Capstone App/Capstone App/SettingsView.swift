import SwiftUI

enum TextSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { self.rawValue }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var isLargeTextEnabled = false
    @State private var selectedTextSize: TextSize = .medium
    @State private var isVoiceOverEnabled = false
    @State private var isHighContrastEnabled = false
    @State private var dataSaveEnabled = false
    @State private var allowLocation = false
    @State private var allowNotifications = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("General Settings").fontWeight(.bold),
                            footer: Text("General settings include preferences for app behavior.")) {
                        Toggle(isOn: $dataSaveEnabled) {
                            Text("Enable Data Saving")
                        }
                        Toggle(isOn: $allowLocation) {
                            Text("Enable Location Services")
                        }
                        Toggle(isOn: $allowNotifications) {
                            Text("Enable Notifications")
                        }
                    }
                    Section(header: Text("Account").fontWeight(.bold),
                            footer: Text("Manage your account settings.")) {
                        NavigationLink(destination: Text("Profile Details")) {
                            Text("Profile")
                        }
                        NavigationLink(destination: Text("Security Settings")) {
                            Text("Security")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("SIGN OUT")
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Settings")
            .scrollContentBackground(.hidden)
        }
    }
}
