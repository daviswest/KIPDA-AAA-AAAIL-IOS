import SwiftUI
import UIKit
import Firebase
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("App Launch: Configuring Firebase and registering for push notifications")
        FirebaseApp.configure()
        
        registerForPushNotifications(application: application)
        setupAuthStateListener()
        return true
    }
    
    private func setupAuthStateListener() {
        print("Setting up auth state listener")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                print("User is signed in with UID: \(user.uid)")

                self?.updateCurrentUserFCMToken()
            } else {
                print("No user is signed in.")

            }
        }
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        print("Registering for push notifications")
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            print("Authorization request completed with permission: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        Messaging.messaging().delegate = self
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS Registration successful, preparing to set APNS token in Messaging")
        print("APNS token retrieved: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken
        

        updateCurrentUserFCMToken()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNS Registration failed")
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Registration token received")
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token: \(fcmToken)")
        
        if let userId = Auth.auth().currentUser?.uid {
            updateFCMTokenInFirestore(fcmToken, forUserId: userId)
        } else {
            print("No signed-in user available, can't update token in Firestore.")
        }
    }

    func updateCurrentUserFCMToken(retryCount: Int = 0) {
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("Error fetching current FCM token: \(error)")
                
                if retryCount < 5 {

                    let retryDelay = Double(2 * retryCount)
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                        print("Retrying FCM token fetch. Attempt number: \(retryCount + 1)")
                        self?.updateCurrentUserFCMToken(retryCount: retryCount + 1)
                    }
                } else {
                    print("Max retries reached for FCM token fetch. Aborting.")
                }
            } else if let token = token {
                print("Current FCM token: \(token)")
                if let userId = Auth.auth().currentUser?.uid {
                    self?.updateFCMTokenInFirestore(token, forUserId: userId)
                } else {
                    print("User is not signed in, can't update token in Firestore yet.")

                }
            }
        }
    }


    func updateFCMTokenInFirestore(_ token: String, forUserId userId: String) {
        print("Preparing to update Firestore with new FCM token for user: \(userId)")
        let userRef = Firestore.firestore().collection("users").document(userId)
        print("Updating Firestore with new FCM token for user ID: \(userId)")
        userRef.setData(["fcmToken": token], merge: true) { error in
            if let error = error {
                print("Error updating token: \(error)")
            } else {
                print("Token successfully updated for user ID: \(userId)")
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification will present in foreground")
        completionHandler([.list, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received with user interaction")

        completionHandler()
    }
}


@main
struct Capstone_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var languageSettings = LanguageSettings()
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageSettings)
                .environmentObject(authManager)
        }
    }
}
