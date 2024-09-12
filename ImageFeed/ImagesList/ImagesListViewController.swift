//
//  ViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 01/09/2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
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
        cell.ImageView.image = image
        let currentDate = Date()
        cell.Label.text = dateFormatter.string(from: currentDate)
        
        let isEvenIndex = indexPath.row % 2 == 0
        let likeImageName = isEvenIndex ? "Active" : "No Active"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
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
}


