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
    @State private var notificationsEnabled = false
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Accessibility Settings").fontWeight(.bold),
                        footer: Text("Customize your experience to suit your needs.")) {
                    Toggle(isOn: $isLargeTextEnabled) {
                        Text("Larger Text")
                    }
                    
                    if isLargeTextEnabled {
                        Picker("Text Size", selection: $selectedTextSize) {
                            ForEach(TextSize.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Toggle(isOn: $isVoiceOverEnabled) {
                        Text("VoiceOver Guidance")
                    }
                    Toggle(isOn: $isHighContrastEnabled) {
                        Text("High Contrast Mode")
                    }
                }

                Section(header: Text("General Settings").fontWeight(.bold),
                        footer: Text("General settings include preferences for app behavior.")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                    }
                    Toggle(isOn: $isDarkModeEnabled) {
                        Text("Dark Mode")
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
                
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.red)
                    .cornerRadius(10)
                    .padding(.vertical, 5)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AuthenticationManager())
    }
}
