
import Foundation
import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
    func updateTableView(oldCount: Int)
    func reloadCell(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    func updateTableView(oldCount: Int) {
        view?.updateTableView(oldCount: oldCount)
    }
    
    func reloadCell(at indexPath: IndexPath) {
        view?.reloadCell(at: indexPath)
    }
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    private var previousPhotosCount: Int = 0
    //private var photosList: [Photo] = []
    var photos: [Photo] {
        return imagesListService.photos
    }
    
    private var imageListObserver: NSObjectProtocol?
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        
        imageListObserver = NotificationCenter.default.addObserver(
               forName: ImagesListService.didChangeNotification,
               object: nil,
               queue: .main
           ) { [weak self] _ in
               guard let self = self else { return }
               let newCount = self.photos.count
               let oldCount = self.previousPhotosCount
               self.previousPhotosCount = newCount
               self.view?.updateTableView(oldCount: oldCount)
           }

           previousPhotosCount = photos.count
           imagesListService.fetchPhotosNextPage()
        
    }
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.view?.updateTableView()
                    self.view?.reloadCell(at: indexPath)
                }
            case .failure(let error):
                print("Ошибка изменения лайка: \(error)")
            }
        }
    }
}

