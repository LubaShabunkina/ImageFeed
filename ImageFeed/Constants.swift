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
    
    static let defaultBaseURL: URL = {
        guard let url = URL (string: "https://api.unsplash.com") else { 
            fatalError("Invalid URL for defaultBaseURL")
        }
        return url
    }()
}

