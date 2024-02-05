import SwiftUI

struct MainTabView: View {
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
                .accentColor(Color(red: 0 / 255, green: 129 / 255, blue: 246 / 255))
        }
    }
}
