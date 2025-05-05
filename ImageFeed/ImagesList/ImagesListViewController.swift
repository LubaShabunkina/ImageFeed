//
//  ViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 01/09/2024.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableView()
    func reloadCell(at indexPath: IndexPath)
    func updateTableView(oldCount: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter = ImagesListPresenter()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
   // private let imagesListService = ImagesListService()
    //private var photos: [Photo] = []
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
        
        presenter.view = self
        presenter.viewDidLoad()
        
       // imagesListService.fetchPhotosNextPage()
    }
    
    func reloadCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateTableView() {
        tableView.reloadData()
    }

    func updateTableView(oldCount: Int) {
        let newCount = presenter.photos.count
        guard newCount > oldCount else { return }

        let newIndexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }

        tableView.performBatchUpdates {
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = presenter.photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
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
        let photo = presenter.photos[indexPath.row]
        
        let url = URL(string: photo.largeImageURL)
        cell.setImage(with: url)
        
        let date = photo.createdAt.map { dateFormatter.string(from: $0) } ?? "—"
        let isLiked = photo.isLiked
        let model = ImagesListCellModel(imageURL: url, date: date, isLiked: isLiked)
        cell.configure(with: model)
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let photo = photos[indexPath.row]
        //let singleImageVC = SingleImageViewController()
        // singleImageVC.imageURL = URL(string: photo.largeImageURL)
        // singleImageVC.imageURL = photo.largeImageURL
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photos.count - 1 {
            presenter.willDisplayCell(at: indexPath)
            
        }
    }
}
    
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    }


