//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 08/09/2024.
//


import UIKit

struct ImagesListCellModel {
    let image: UIImage?
    let date: String
    let isLiked: Bool
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet private weak var ImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet private weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    func configure(with model: ImagesListCellModel) {
        ImageView.image = model.image
        dateLabel.text = model.date
        let likeButtonImage = model.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "No Active")
        likeButton.setImage(likeButtonImage, for: .normal)
    }
}
