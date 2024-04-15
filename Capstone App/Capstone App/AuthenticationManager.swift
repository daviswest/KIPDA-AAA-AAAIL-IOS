import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isGuest = false
    @Published var isAdmin = false

    init() {
        isAuthenticated = Auth.auth().currentUser != nil
        fetchUserRole()
    }
    
    func fetchUserRole() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isAdmin = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    if let role = data?["role"] as? String, role == "admin" {
                        self?.isAdmin = true
                    } else {
                        self?.isAdmin = false
                    }
                } else {
                    self?.isAdmin = false
                    print("Document does not exist or failed to fetch user role: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let user = authResult?.user, error == nil {
                    self?.isAuthenticated = true
                    self?.isGuest = false
                    print("Successfully logged in user: \(user.email ?? "Unknown email")")
                    self?.fetchUserRole()
                    completion(true, nil)
                } else {
                    print("Login error: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false, error?.localizedDescription)
                }
            }
        }
    }

    func continueAsGuest() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                print("User signed in anonymously with UID: \(user.uid)")
                self.createUserDocument(for: user) {
                    DispatchQueue.main.async {
                        self.isAdmin = false
                        self.isGuest = true
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }

        
    private func createUserDocument(for user: User, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.setData([
            "uid": user.uid,
            "createdAt": FieldValue.serverTimestamp(),
            "hiddenNotifications": []
        ], merge: true) { error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
            } else {
                print("User document successfully created or updated with hiddenNotifications initialized")
            }
            completion()
        }
    }


    func linkAnonymousAccountToEmail(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser, currentUser.isAnonymous else {
            completion(false, nil)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        currentUser.link(with: credential) { (authResult, error) in
            if let error = error {
                print("Failed to link anonymous account: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            completion(true, nil)
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
    
    func register(email: String, password: String, firstName: String, lastName: String, county: String, completion: @escaping (Bool, String?) -> Void) {
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
                "county": county // This line is changed to store the selected county
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
}
