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

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet private weak var ImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    
    @IBOutlet private weak var likeButton: UIButton!
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    
    func setImage(with url: URL?) {
            ImageView.kf.setImage(with: url)
        }
    
    func setIsLiked(_ isLiked: Bool) {
           likeButton.isSelected = isLiked
       }
   
    func configure(with model: ImagesListCellModel) {
        if let imageURL = model.imageURL {
            ImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(named: "placeholder"),
                options: [.transition(.fade(0.3))]
            )
        } else {
            ImageView.image = UIImage(named: "placeholder")
        }
        
        dateLabel.text = model.date
        setIsLiked(model.isLiked)
    }
}
