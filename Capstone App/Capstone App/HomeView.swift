import SwiftUI

struct HomeView: View {
    @EnvironmentObject var languageSettings: LanguageSettings

    var body: some View {
        NavigationView {
            VStack {
                Text("This is the home screen")
                    .padding(.bottom, 20)

                Spacer()
            }
            .padding()
        }
    }
}
