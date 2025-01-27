import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: PhotoURLs
    let likedByUser: Bool
}

struct PhotoURLs: Codable {
    let thumb: String
    let full: String
}

extension ImagesListService {
    func convertToPhotos(from photoResults: [PhotoResult]) -> [Photo] {
        return photoResults.compactMap { photoResult in
            guard
                let thumbImageURL = URL(string: photoResult.urls.thumb),
                let largeImageURL = URL(string: photoResult.urls.full)
            else {
                return nil
            }
            
            let createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
            let size = CGSize(width: photoResult.width, height: photoResult.height)
            
            return Photo(
                id: photoResult.id,
                size: size,
                createdAt: createdAt,
                welcomeDescription: photoResult.description,
                thumbImageURL: thumbImageURL.absoluteString,
                largeImageURL: largeImageURL.absoluteString,
                isLiked: photoResult.likedByUser
            )
        }
    }
}
