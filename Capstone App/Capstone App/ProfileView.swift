import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var zipCode: String = ""
    @State private var showConfirmationDialog = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var userID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        Text("First Name")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Text("Last Name")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Text("Zip Code")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        TextField("Zip Code", text: $zipCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Save Changes Button
                Button(action: {
                    showConfirmationDialog = true
                }) {
                    Text("SAVE CHANGES")
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        
        .confirmationDialog("Are you sure you want to make these changes?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Yes, Save Changes", role: .destructive) {
                saveProfileChanges()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Update Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            fetchUserProfile()
        }
        .navigationBarTitle("Edit Profile", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private func fetchUserProfile() {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.firstName = data?["firstName"] as? String ?? ""
                self.lastName = data?["lastName"] as? String ?? ""
                self.zipCode = data?["zipCode"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func saveProfileChanges() {
        let db = Firestore.firestore()
        db.collection("users").document(userID).updateData([
            "firstName": firstName,
            "lastName": lastName,
            "zipCode": zipCode
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}

// Ensure your project is configured with Firebase and the Firestore SDK is included in your project.
// This example also assumes the user is authenticated and a valid userID is available.
