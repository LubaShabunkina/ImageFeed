//
//  Untitled.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 30/11/2024.
//
import Foundation

// Структура для декодирования ответа от API Unsplash
struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

// Структура для использования в UI
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

// Сервис для получения данных профиля
final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    private(set) var currentProfile: Profile? // Сохраняем текущий профиль
    
    private var activeRequest: Bool = false
    private let queue = DispatchQueue(label: "ProfileServiceQueue", attributes: .concurrent)
    
    var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        queue.async(flags: .barrier) {
            if self.activeRequest {
                completion(.failure(NSError(domain: "RequestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
                return
            }
            self.activeRequest = true
        }
        
        guard let request = makeProfileRequest(token: token) else {
            queue.async(flags: .barrier) {
                self.activeRequest = false
            }
            completion(.failure(NSError(domain: "RequestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create profile request"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.queue.async(flags: .barrier) {
                self?.activeRequest = false
            }
            if let error = error {
                print("Error during profile fetch: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(httpResponse.statusCode)"])))
                return
            }
            
            guard let data = data else {
                print("Error: No data received from profile request")
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let profile = try self?.decodeProfile(from: data)
                self?.queue.async(flags: .barrier) {
                    self?.currentProfile = profile
                }
                if let profile = profile {
                    completion(.success(profile))
                } else {
                    completion(.failure(NSError(domain: "DecodeError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode profile"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        
        /*if let error = error {
         completion(.failure(error))
         return
         }
         
         guard let data = data else {
         completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
         return
         }
         
         do {
         let result = try JSONDecoder().decode(ProfileResult.self, from: data)
         let profile = Profile(
         username: result.username,
         name: "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces),
         loginName: "@\(result.username)",
         bio: result.bio
         )
         completion(.success(profile))
         } catch {
         completion(.failure(error))
         }
         }
         
         task.resume()*/
    }
    // Вспомогательный метод для декодирования
    private func decodeProfile(from data: Data) throws -> Profile {
        let result = try JSONDecoder().decode(ProfileResult.self, from: data)
        return Profile(
            username: result.username,
            name: "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces),
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
    
    // Вспомогательный метод для создания URLRequest
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Invalid URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
