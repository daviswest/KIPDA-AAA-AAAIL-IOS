import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var countySelected: String = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            Text("We're glad you're here")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 60)
            
            Text("Please fill out some details to register")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            VStack(spacing: 20) {
                Group {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    PasswordField(placeholder: "Password", password: $password)
                    PasswordField(placeholder: "Confirm Password", password: $confirmPassword)
                    
                    Picker(selection: $countySelected, label: Text(countySelected.isEmpty ? "Select County" : countySelected)) {
                        Text("Select County").tag("")
                        Text("Jefferson").tag("Jefferson")
                        Text("Bullitt").tag("Bullitt")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, maxHeight: 30)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(5)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
            }
            
            Button(action: performRegistration) {
                Text("REGISTER")
                    .foregroundColor(.white)
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(false)
        }
    }

    func performRegistration() {
        guard !countySelected.isEmpty else {
            errorMessage = "Please select a county."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        authManager.register(email: email, password: password, firstName: firstName, lastName: lastName, countySelected: countySelected) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    print("Registration successful")
                } else {
                    self.errorMessage = errorMessage ?? "An error occurred during registration."
                }
            }
        }
    }
}
