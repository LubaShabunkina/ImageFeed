//
//  ViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 01/09/2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter .timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            return
        }
        cell.imageView?.image = image
        let currentDate = Date()
        cell.Label.text = dateFormatter.string(from: currentDate)
        
        let isEvenIndex = indexPath.row % 2 == 0
        let likeImageName = isEvenIndex ? "Active" : "NoActive"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController, // 2
                let indexPath = sender as? IndexPath // 3
         else {
                assertionFailure("Invalid segue destination") // 4
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            _ = viewController.view
            viewController.imageView.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

    
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
        
        extension ImagesListViewController: UITableViewDelegate {
            internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                let imageName = photosName[indexPath.row]
                guard let image = UIImage(named: imageName) else {
                    return 200
                    
                }
                let tableViewWidth = tableView.bounds.width
                let aspectRatio = image.size.height / image.size.width
                let imageViewHight = tableViewWidth * aspectRatio
                let padding: CGFloat = 24
                
                return imageViewHight + padding
            }
            
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
            }
        }
    
