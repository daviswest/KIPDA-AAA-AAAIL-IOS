import SwiftUI

@main
struct Capstone_AppApp: App {
    @StateObject var languageSettings = LanguageSettings()

    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "languageSet") {
                WelcomeView().environmentObject(languageSettings)
            } else {
                SetLanguageView().environmentObject(languageSettings)
            }
        }
    }
}
