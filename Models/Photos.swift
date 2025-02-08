import UIKit


public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: PhotoURLs
    let likedByUser: Bool
    
 /*   enum CodingKeys: String, CodingKey {
           case id, width, height, description, urls
           case createdAt = "created_at"
           case likedByUser = "liked_by_user"
       }*/
}

struct PhotoURLs: Codable {
    let thumb: String
    let full: String
}

extension ImagesListService {
    func convertToPhotos(from photoResults: [PhotoResult]) -> [Photo] {
        return photoResults.compactMap { photoResult in
            let createdAt = photoResult.createdAt.flatMap {
                ISO8601DateFormatter().date(from: $0)
            }
            
            let size = CGSize(width: photoResult.width, height: photoResult.height)
            
            return Photo(
                id: photoResult.id,
                size: size,
                createdAt: createdAt,
                description: photoResult.description,
                thumbImageURL: photoResult.urls.thumb,
                largeImageURL: photoResult.urls.full,
                isLiked: photoResult.likedByUser
            )
        }
    }
}
