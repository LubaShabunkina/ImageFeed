//
//  Constants.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import Foundation

enum Constants {
    static let accessKey = "r8vMQV7TIb4M1g2DvzmuoY91biwYXo-xlC77-kFLFvk"
    static let secretKey = "6dCZN7nHTmEGF2OnRP1y4TExg_BBtmpvgBuIXT8sLT0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let photosPath = "/photos"
    static let photosURL = defaultBaseURL.appendingPathComponent(photosPath)
    static let userProfilePath = "/users"
    static func userProfileURL(for username: String) -> URL {
        return defaultBaseURL.appendingPathComponent("\(userProfilePath)/\(username)")
    }
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL for defaultBaseURL")
        }
        return url
    }()
    
    static let authPath = "/oauth/authorize"
    static let authURL = "https://unsplash.com\(authPath)"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
