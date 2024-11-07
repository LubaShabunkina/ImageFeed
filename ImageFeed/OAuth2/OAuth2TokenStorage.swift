//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 22/10/2024.
//

import Foundation

final class OAuth2TokenStorage {
    
     let tokenKey = "oauth_token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
