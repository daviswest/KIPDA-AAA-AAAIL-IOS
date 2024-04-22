import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("home_tab_label", comment: "Title for the home section"), systemImage: "house.fill")
                }
            
            ServicesView()
                .tabItem {
                    Label(NSLocalizedString("resources_tab_label", comment: "Title for the resources section"), systemImage: "info.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label(NSLocalizedString("settings_tab_label", comment: "Title for the settings section"), systemImage: "gearshape.fill")
                }
            
            if authManager.isAdmin {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "lock.fill")
                    }
            }
        }
    }
}
