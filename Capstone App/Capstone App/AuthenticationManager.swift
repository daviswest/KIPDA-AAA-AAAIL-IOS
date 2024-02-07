import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isGuest = false
    
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let user = authResult?.user, error == nil {
                    self?.isAuthenticated = true
                    self?.isGuest = false
                    print("Successfully logged in user: \(user.email ?? "Unknown email")")
                    completion(true, nil)
                } else {
                    print("Login error: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            isGuest = false
        } catch let signOutError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    func register(email: String, password: String, firstName: String, lastName: String, zipCode: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, "Registration error: \(error.localizedDescription)")
                    print(error)
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    completion(false, "User data unavailable after registration.")
                }
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "zipCode": zipCode
            ]) { err in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(false, "Firestore error: \(err.localizedDescription)")
                        print(err)
                    } else {
                        self?.isAuthenticated = true
                        completion(true, nil)
                    }
                }
            }
        }
    }

    
    func continueAsGuest() {
        isAuthenticated = false
        isGuest = true
    }
}
