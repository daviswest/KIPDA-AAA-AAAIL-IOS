import SwiftUI

struct ContentView: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        Group {
            if authManager.isAuthenticated || authManager.isGuest {
                MainTabView()
            } else {
                if languageSettings.selectedLanguage != nil {
                    WelcomeView()
                } else {
                    SetLanguageView()
                }
            }
        }
    }
}
