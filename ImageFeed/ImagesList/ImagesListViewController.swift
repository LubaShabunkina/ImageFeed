//
//  ViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 01/09/2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    private var imageListObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter .timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        imageListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let updatedPhotos = notification.userInfo?["photos"] as? [Photo] {
                print("Before update: \(self.photos.count)")
                self.photos = updatedPhotos
                print("After update: \(self.photos.count)")
                self.updateTableView()
            }
        }
        
        // Загружаем первую страницу фотографий
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updateTableView() {
           tableView.performBatchUpdates {
               let startIndex = max(0, photos.count - 10)
               let newIndexPaths = (startIndex..<photos.count).map { IndexPath(row: $0, section: 0) }
               tableView.insertRows(at: newIndexPaths, with: .automatic)
           }
       }
   
    
   /* @objc private func updateTableViewAnimated(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let newPhotos = userInfo["photos"] as? [Photo] else { return }
        
        let oldCount = photos.count
        let newCount = newPhotos.count
        
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            photos = newPhotos
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }*/

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL) // Убираем `UIImage(named:)`
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let url = URL(string: photo.largeImageURL)
        cell.setImage(with: url)
        
        let date = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : "—"
        let isLiked = photo.isLiked
        
        // Создаем модель
        let model = ImagesListCellModel(imageURL: url, date: date, isLiked: isLiked)
        
        // Конфигурируем ячейку через метод
        cell.configure(with: model)
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
            
        }
    }
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
    
      guard let indexPath = tableView.indexPath(for: cell) else { return }
      let photo = photos[indexPath.row]
      // Покажем лоадер
     UIBlockingProgressHUD.show()
     imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
        switch result {
        case .success:
           // Синхронизируем массив картинок с сервисом
           self.photos = self.imagesListService.photos
           // Изменим индикацию лайка картинки
           cell.setIsLiked(self.photos[indexPath.row].isLiked)
           // Уберём лоадер
           UIBlockingProgressHUD.dismiss()
        case .failure:
           // Уберём лоадер
           UIBlockingProgressHUD.dismiss()
           // Покажем, что что-то пошло не так
           // TODO: Показать ошибку с использованием UIAlertController
           }
        }
    }
    
}
