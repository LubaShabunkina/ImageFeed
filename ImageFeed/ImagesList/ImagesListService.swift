//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 24/01/2025.
//

import Foundation
import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var isLoading = false
    private var currentPage = 0
    private let tokenStorage: OAuth2TokenStorage
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage(), session: URLSession = .shared) {
        self.tokenStorage = tokenStorage
        self.session = session
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        guard let token = tokenStorage.token else {
            print("Ошибка: отсутствует токен")
            return
        }
        
        isLoading = true
        currentPage += 1
        let url = URL(string: "https://api.unsplash.com/photos?page=\(currentPage)&per_page=10")! // Замените параметры на нужные

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Ошибка: нет данных")
                return
            }

            do {
                let photoResults = try self.decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { self.convertToPhoto(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    private func convertToPhoto(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        let createdAt = ISO8601DateFormatter().date(from: result.createdAt)
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
