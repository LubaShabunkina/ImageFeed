import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {

    func testViewDidLoadFetchesPhotos() {
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let view = ImagesListViewControllerSpy()
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled, "fetchPhotosNextPage должен быть вызван при viewDidLoad")
    }

    func testWillDisplayCellFetchesNextPage() {
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)

        presenter.willDisplayCell(at: IndexPath(row: 9, section: 0))

        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled, "fetchPhotosNextPage должен быть вызван при показе последней ячейки")
    }

    func testDidTapLikeUpdatesPhotoAndReloadsCell() {
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let view = ImagesListViewControllerSpy()
        presenter.view = view

        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, description: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        imagesListService.setPhotos([photo])
        presenter.viewDidLoad()

        presenter.didTapLike(at: IndexPath(row: 0, section: 0))

        XCTAssertTrue(view.reloadCellCalled, "reloadCell должен быть вызван после смены лайка")
        XCTAssertTrue(imagesListService.photos[0].isLiked, "Фото должно быть залайкано")
    }
}

// Протокол сервиса
/*protocol ImagesListServiceProtocol {
    var photos: [Photo] { get set }
    func fetchPhotosNextPage()
}*/

// Мок контроллера
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewCalled = false
    var reloadCellCalled = false
    var reloadIndexPath: IndexPath?

    func updateTableView() {
        updateTableViewCalled = true
    }

    func reloadCell(at indexPath: IndexPath) {
        reloadCellCalled = true
        reloadIndexPath = indexPath
    }

    func updateTableView(oldCount: Int) {
        updateTableViewCalled = true
    }
}

// Мок сервиса
final class ImagesListServiceSpy: ImagesListServiceProtocol {
    private(set) var fetchPhotosNextPageCalled = false
    private(set) var changeLikeCalled = false
    private(set) var lastPhotoId: String?
    private(set) var lastIsLike: Bool?
    
    private(set) var photosInternal: [Photo] = []
    var photos: [Photo] {
        get { photosInternal }
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        lastPhotoId = photoId
        lastIsLike = isLike

        if let index = photosInternal.firstIndex(where: { $0.id == photoId }) {
            let old = photosInternal[index]
            let updated = Photo(
                id: old.id,
                size: old.size,
                createdAt: old.createdAt,
                description: old.description,
                thumbImageURL: old.thumbImageURL,
                largeImageURL: old.largeImageURL,
                isLiked: !old.isLiked
            )
            photosInternal[index] = updated
        }

        completion(.success(()))
    }

    func setPhotos(_ photos: [Photo]) {
        self.photosInternal = photos
    }
}
