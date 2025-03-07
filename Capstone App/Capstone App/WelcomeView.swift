import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isTapped = false
    @State private var navigateToHome = false
    @State private var navigateToSetLanguage = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("kipda_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 10)
                
                Text(NSLocalizedString("welcome_message", comment: "Welcome to kipda notify"))
                    .font(.system(size: UIScreen.main.bounds.width * 0.05))
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                
                Text(NSLocalizedString("agency_message", comment: "Your agency area on aging"))
                    .font(.system(size: UIScreen.main.bounds.width * 0.04))
                    .padding(.bottom, 50)
                
                NavigationLink(destination: LoginView()) {
                    Text(NSLocalizedString("login_button", comment: "login"))
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(red: 0/255, green: 129/255, blue: 246/255))
                        .cornerRadius(40)
                        .padding(.horizontal, 50)
                        .opacity(isTapped ? 0.5 : 1.0)
                }
                .simultaneousGesture(TapGesture().onEnded { _ in
                    self.isTapped.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isTapped.toggle()
                    }
                })
                
                NavigationLink(destination: RegisterView()) {
                    Text(NSLocalizedString("register_button", comment: "register"))
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(40)
                        .padding(.horizontal, 50)
                        .opacity(isTapped ? 0.5 : 1.0)
                }
                .simultaneousGesture(TapGesture().onEnded { _ in
                    self.isTapped.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isTapped.toggle()
                    }
                })
                
                
                NavigationLink(destination: MainTabView().navigationBarBackButtonHidden(true)) {
                    Text(NSLocalizedString("continue_guest", comment: "continue as guest"))
                        .opacity(isTapped ? 0.5 : 1.0)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    authManager.continueAsGuest()
                    self.navigateToHome = true
                    self.isTapped.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isTapped.toggle()
                    }
                })
                .padding()
                Image("kipda_small_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            .navigationBarHidden(true)
        }
    }
}
