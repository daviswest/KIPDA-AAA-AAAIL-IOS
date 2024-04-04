import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = "Error"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    Text("Current Password")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    SecureField("Current Password", text: $currentPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Text("New Password")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    SecureField("New Password", text: $newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Text("Confirm New Password")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    SecureField("Confirm New Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
                // Update Password Button
                Button(action: {
                    updatePassword()
                }) {
                    Text("CHANGE PASSWORD")
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarTitle("Change Password", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }

    private func updatePassword() {
        guard newPassword == confirmPassword else {
            alertTitle = "Error"
            alertMessage = "New password and confirmation do not match."
            showAlert = true
            return
        }

        let currentUser = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: currentUser?.email ?? "", password: currentPassword)

        currentUser?.reauthenticate(with: credential, completion: { result, error in
            if let error = error {
                alertTitle = "Authentication Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                currentUser?.updatePassword(to: newPassword, completion: { error in
                    if let error = error {
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showAlert = true
                    } else {
                        alertTitle = "Success"
                        alertMessage = "Your password has been updated successfully."
                        showAlert = true
                    }
                })
            }
        })
    }
}
