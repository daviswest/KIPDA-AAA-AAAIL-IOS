import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ServicesView()
                .tabItem {
                    Label("Resources", systemImage: "info.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
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
