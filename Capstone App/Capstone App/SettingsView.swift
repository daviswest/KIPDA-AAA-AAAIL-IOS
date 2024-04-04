import SwiftUI
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var zipCode: String?
    @Published var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("Authorization status: Not determined. Requesting permission...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization status: Authorized. Starting location updates...")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("Authorization status: Default case. Requesting permission...")
            locationManager.requestWhenInUseAuthorization()
            break
        }
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchZipCode(from: location)
        stopLocationUpdates() // Optionally stop updates if you only need the initial location.
    }

    func fetchZipCode(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self, let placemark = placemarks?.first, error == nil else {
                print("Failed to fetch zip code: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.zipCode = placemark.postalCode
        }
    }
    
    func requestNotificationAuthorization() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Failed to request notification authorization: \(error.localizedDescription)")
                } else {
                    self.notificationAuthorizationStatus = granted ? .authorized : .denied
                    print("Notification authorization status: \(self.notificationAuthorizationStatus)")
                }
            }
        }
}


enum TextSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "Extra Large"

    var id: String { self.rawValue }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var locationManager = LocationManager() 
    @State private var allowLocation = false

    @State private var isLargeTextEnabled = false
    @State private var selectedTextSize: TextSize = .medium
    @State private var isVoiceOverEnabled = false
    @State private var isHighContrastEnabled = false
    @State private var dataSaveEnabled = false
    @State private var allowNotifications = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("General Settings").fontWeight(.bold),
                            footer: Text("General settings include preferences for app behavior.")) {
                        Toggle("Enable Location Services", isOn: Binding<Bool>(
                                                    get: { self.allowLocation },
                                                    set: { newValue in
                                                        self.allowLocation = newValue
                                                        if newValue {
                                                            self.locationManager.checkLocationAuthorization()
                                                        } else {
                                                            self.locationManager.stopLocationUpdates()
                                                        }
                                                    }
                                                ))

                        Toggle("Enable Notifications", isOn: Binding<Bool>(
                            get: { self.allowNotifications },
                            set: { newValue in
                                self.allowNotifications = newValue
                                if newValue {
                                    self.locationManager.requestNotificationAuthorization()
                                } else {
                                }
                            }
                        ))

                    }
                    Section(header: Text("Account").fontWeight(.bold),
                            footer: Text("Manage your account settings.")) {
                        NavigationLink(destination: ProfileView().environmentObject(authManager)) {
                            Text("Edit Profile")
                        }
                        NavigationLink(destination: ChangePasswordView().environmentObject(authManager)) {
                            Text("Change Password")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("SIGN OUT")
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Settings")
            .scrollContentBackground(.hidden)
        }
    }
}
