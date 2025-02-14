//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 20/12/2024.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    private var currentTask: URLSessionTask?
    private var lastUsername: String?
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileImage: Codable {
        let small: String
    }
    
    func clearAvatar() {
            avatarURL = nil
        }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard lastUsername != username else { return }
        currentTask?.cancel()
        
        lastUsername = username
        
        let url = Constants.userProfileURL(for: username)
            
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Missing Token", code: 401, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer {
                self.currentTask = nil 
                self.lastUsername = nil
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid Response", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                // Публикуем нотификацию
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
            } catch {
                completion(.failure(error))
            }
        }
        
        currentTask = task
        task.resume()
    }
}
