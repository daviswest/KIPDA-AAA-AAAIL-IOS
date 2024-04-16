import SwiftUI
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var zipCode: String?
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkInitialLocationAuthorization()
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("Authorization status: Not determined. Requesting permission...")
            requestAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization status: Authorized. Starting location updates...")
            startLocationUpdates()
        default:
            print("Authorization status: Denied or Restricted.")
        }
    }
    
    func checkInitialLocationAuthorization() {
        notificationAuthorizationStatus = locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse ? .authorized : .denied
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        notificationAuthorizationStatus = manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse ? .authorized : .denied
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchZipCode(from: location)
        stopLocationUpdates()
    }

    func fetchZipCode(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let placemark = placemarks?.first {
                self?.zipCode = placemark.postalCode
            }
        }
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationAuthorizationStatus = granted ? .authorized : .denied
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var locationManager = LocationManager()
    @State private var allowLocation = false
    @State private var allowNotifications = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("General Settings").fontWeight(.bold)) {
                        Toggle("Enable Location Services", isOn: $allowLocation)
                            .onChange(of: allowLocation) { newValue in
                                if newValue {
                                    locationManager.requestAuthorization()
                                } else {
                                    locationManager.stopLocationUpdates()
                                }
                            }

                        Toggle("Enable Notifications", isOn: $allowNotifications)
                            .onChange(of: allowNotifications) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                                if newValue {
                                    locationManager.requestNotificationAuthorization()
                                } else {
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                }
                            }
                    }
                    Section(header: Text("Account").fontWeight(.bold)) {
                        NavigationLink(destination: ProfileView().environmentObject(authManager)) {
                            Text("Edit Profile")
                        }
                        NavigationLink(destination: ChangePasswordView().environmentObject(authManager)) {
                            Text("Change Password")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Button("SIGN OUT") {
                    authManager.signOut()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Settings")
            .onAppear {
                allowLocation = locationManager.notificationAuthorizationStatus == .authorized
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        allowNotifications = settings.authorizationStatus == .authorized
                    }
                }
            }
        }
    }
}
