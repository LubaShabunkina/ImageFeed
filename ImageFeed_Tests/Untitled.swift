import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    func testViewDidLoadFetchesPhotos() {
        // given
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled, "fetchPhotosNextPage should be called on viewDidLoad")
    }
    
    func testWillDisplayCellFetchesNextPage() {
        // given
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        
        // when
        presenter.willDisplayCell(at: IndexPath(row: 9, section: 0))
        
        // then
        XCTAssertTrue(imagesListService.fetchPhotosNextPageCalled, "fetchPhotosNextPage should be called when last cell is displayed")
    }
    
    func testDidTapLikeUpdatesPhotoAndReloadsCell() {
        // given
        let imagesListService = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let view = ImagesListViewControllerSpy()
        presenter.view = view
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, description: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        imagesListService.setPhotos([photo]) // Используем setPhotos вместо присваивания
        
        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(view.reloadCellCalled, "reloadCell should be called after liking a photo")
        XCTAssertTrue(imagesListService.photos[0].isLiked, "Photo should be marked as liked")
    }
}

// Протокол сервиса
protocol ImagesListServiceProtocol {
    var photos: [Photo] { get set }
    func fetchPhotosNextPage()
}

// Мок контроллера
final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewCalled = false
    var reloadCellCalled = false
    
    func updateTableView() {
        updateTableViewCalled = true
    }
    
    func reloadCell(at indexPath: IndexPath) {
        reloadCellCalled = true
    }
}

// Мок сервиса
final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var fetchPhotosNextPageCalled = false
    var photos: [Photo] = [] // Убрали private(set), чтобы был доступ к изменению
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func setPhotos(_ newPhotos: [Photo]) {
        photos = newPhotos
    }
}
