//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 08/09/2024.
//


import UIKit
import Kingfisher

struct ImagesListCellModel {
    let imageURL: URL?
    let date: String
    let isLiked: Bool
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet private weak var ImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet private weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    func configure(with model: ImagesListCellModel) {
        if let imageURL = model.imageURL {
            ImageView.kf.setImage(with: imageURL) // Загружаем картинку из сети
        } else {
            ImageView.image = nil // Если URL нет, очищаем изображение
        }
        
        dateLabel.text = model.date
        let likeButtonImage = model.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "No Active")
        likeButton.setImage(likeButtonImage, for: .normal)
    }
}
