import SwiftUI

// Defines a class 'LanguageSettings' which will observe and respond to changes in language settings. This is necessary so the app doesn't have to restart every time the language is changed.
class LanguageSettings: ObservableObject {

    // A published property that stores the currently selected language.
    // It uses UserDefaults to persist the language setting and defaults to English ('en') if no value is stored.
    @Published var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en" {
        didSet {
            // Whenever the selectedLanguage changes, update the UserDefaults and set the new language for the app.
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.set(true, forKey: "languageSet")
            Bundle.setLanguage(selectedLanguage)
        }
    }
}

// Extending the Bundle class to support dynamic language switching.
extension Bundle {
    
    // A fileprivate static variable used as a unique key for associated objects in the Bundle class.
    fileprivate static var bundleKey: UInt8 = 0

    // A static method to change the language of the app.
    static func setLanguage(_ language: String) {
        // Ensures thread safety when accessing/modifying the bundle.
        objc_sync_enter(self)
        defer { objc_sync_exit(self) } // Ensures the exit code is called in all cases.

        // Check if the current Bundle.main is already a PrivateBundle instance; if not, set its class to PrivateBundle.
        if object_getClass(Bundle.main) != PrivateBundle.self {
            object_setClass(Bundle.main, PrivateBundle.self)
        }

        // Associates a new localized bundle with Bundle.main for the given language.
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main.localizedBundle(for: language), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // Computed property to get the localized bundle associated with the current Bundle.main.
    var localizedBundle: Bundle? {
        return objc_getAssociatedObject(self, &Bundle.bundleKey) as? Bundle
    }

    // Method to get a localized bundle for a given language.
    func localizedBundle(for language: String) -> Bundle? {
        // Looks for a .lproj folder for the given language and creates a new Bundle from its path if found.
        guard let path = self.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return nil }
        return bundle
    }
}

// A private subclass of Bundle used to override the localizedString(forKey:value:table:) method.
private class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Tries to get a localized string from the associated bundle. If not found falls back to default implementation
        guard let bundle = objc_getAssociatedObject(self, &Bundle.bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
