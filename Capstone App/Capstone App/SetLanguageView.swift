import SwiftUI

struct SetLanguageView: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    @State private var isPresentingWelcomeView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text(NSLocalizedString("language_message", comment: "Choose language"))
                    .font(.title2)
                    .fontWeight(.bold)
                Picker("Select Language", selection: $selectedLanguage) {
                    Text("English").tag("en")
                    Text("Somali").tag("so")
                    Text("Arabic").tag("ar")
                    Text("Persian").tag("fa")
                }
                .pickerStyle(WheelPickerStyle())
                .padding()

                Button("Save Language") {
                    languageSettings.selectedLanguage = selectedLanguage
                    isPresentingWelcomeView = true
                }
                .padding()
            }
            .navigationDestination(isPresented: $isPresentingWelcomeView) {
                WelcomeView().environmentObject(languageSettings).navigationBarBackButtonHidden(true)
            }
        }
    }
}

