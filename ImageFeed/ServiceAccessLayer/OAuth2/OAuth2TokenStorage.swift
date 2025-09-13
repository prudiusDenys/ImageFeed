import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let dataStorage =  KeychainWrapper.standard
    private let tokenKey = "token"

    var token: String? {
        get {
            dataStorage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
}
