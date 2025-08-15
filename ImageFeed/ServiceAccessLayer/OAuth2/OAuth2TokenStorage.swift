import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "oauth2_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "oauth2_token")
        }
    }
}
