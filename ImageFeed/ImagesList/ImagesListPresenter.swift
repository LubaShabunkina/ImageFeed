
import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    
    private var photosList: [Photo] = []
    var photos: [Photo] {
        return imagesListService.photos
    }
    
    private var imageListObserver: NSObjectProtocol?
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared as! ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let updatedPhotos = notification.userInfo?["photos"] as? [Photo] {
                self.photosList = updatedPhotos
                self.view?.updateTableView()
            }
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        var photo = photos[indexPath.row]
        photo.isLiked.toggle()
        photosList[indexPath.row] = photo
        view?.reloadCell(at: indexPath)
    }
}
