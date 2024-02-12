import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView{
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 60)
            
            Text("Please login to continue")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        
            VStack(spacing: 20) {
                Group {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    PasswordField(placeholder: "Password", password: $password)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
        }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
            }
            
            Button(action: {
                performLogin()
            }) {
                Text("LOGIN")
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color(red: 0/255, green: 129/255, blue: 246/255))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            Spacer()
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }

    func performLogin() {
        authManager.signIn(email: email, password: password) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                } else {
                    self.errorMessage = errorMessage
                }
            }
        }
    }
}
