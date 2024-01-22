import SwiftUI

@main
struct Capstone_AppApp: App {
    @StateObject var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            if languageSettings.selectedLanguage != nil {
                WelcomeView().environmentObject(languageSettings)
            } else {
                SetLanguageView().environmentObject(languageSettings)
            }
        }
    }
}
