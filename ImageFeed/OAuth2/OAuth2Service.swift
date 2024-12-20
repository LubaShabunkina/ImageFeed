//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 21/10/2024.
//

import UIKit
import ProgressHUD


// Структура для парсинга ответа сервера
struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let createdAt: Int
    
    // Используем ключи, чтобы соответствовать названиям в JSON
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    var token: String? = nil
    let tokenStorage = OAuth2TokenStorage()
    
    private var activeRequests: [String: [(Result<String, Error>) -> Void]] = [:]
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue", attributes: .concurrent)
    
    func fetchToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async(flags: .barrier) {
            if self.activeRequests[code] != nil {
                // Если запрос с этим code уже выполняется, добавляем замыкание
                self.activeRequests[code]?.append(completion)
                return
            } else {
                // Инициализируем массив ожиданий для нового кода
                self.activeRequests[code] = [completion]
            }
        }
        // Создаём запрос
                guard let request = makeOAuthTokenRequest(code: code) else {
                    complete(code: code, with: .failure(NSError(domain: "RequestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create OAuth token request."])))
                    return
                }
                
                // Выполняем запрос
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        self.complete(code: code, with: .failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        self.complete(code: code, with: .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                        return
                    }
                    
                    do {
                        let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        self.tokenStorage.token = tokenResponse.accessToken
                        self.complete(code: code, with: .success(tokenResponse.accessToken))
                    } catch {
                        self.complete(code: code, with: .failure(error))
                    }
                }
                task.resume()
            }
    // Завершение всех запросов для указанного кода
        private func complete(code: String, with result: Result<String, Error>) {
            queue.async(flags: .barrier) {
                let completions = self.activeRequests[code]
                self.activeRequests[code] = nil
                completions?.forEach { $0(result) }
            }
        }
    // Метод для создания запроса
        private func makeOAuthTokenRequest(code: String) -> URLRequest? {
            guard let baseURL = URL(string: "https://unsplash.com") else {
                print("Invalid base URL")
                return nil
            }
        
      /*  func fetchAuthCode(from viewController: UIViewController, completion: @escaping
                           (Result<String, Error>) -> Void) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else {
                completion(.failure(NSError(domain: "ViewControllerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to instantiate WebViewViewController."])))
                return
            }
            
            webViewController.delegate = viewController as? WebViewViewControllerDelegate
            
            // Показ webViewController
            viewController.present(webViewController, animated: true, completion: nil)
        }
        
        // Метод для создания запроса
        func makeOAuthTokenRequest(code: String) -> URLRequest? {
            guard let baseURL = URL(string: "https://unsplash.com") else {
                print("Invalid base URL")
                return nil
            }*/
            
            guard let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
            ) else {
                print("Invalid token URL")
                return nil
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            return request
        }
    }

    
