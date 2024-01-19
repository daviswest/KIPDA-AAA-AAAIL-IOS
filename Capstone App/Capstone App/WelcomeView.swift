import SwiftUI

struct WelcomeView: View {
    @State private var isTapped = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("kipda_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 300)

                Text("Welcome to KIPDA Notify")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)

                NavigationLink(destination: LoginView()) {
                    Text("Login")
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
                    Text("Register")
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
                Spacer()
            }
            .padding()
        }
    }
}
