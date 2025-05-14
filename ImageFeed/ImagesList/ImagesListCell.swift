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
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
        
    }
    
    weak var delegate: ImagesListCellDelegate?
    
    static let reuseIdentifier = "ImagesListCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.setImage(UIImage(named: "NoActive"), for: .normal)
        likeButton.setImage(UIImage(named: "ActiveLike"), for: .selected)
    }
    
    func setImage(with url: URL?) {
        ImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.3))]
        )
    }
    
    func setIsLiked(_ isLiked: Bool) {
        likeButton.isSelected = isLiked
        likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
    }
    
    func configure(with model: ImagesListCellModel) {
        setImage(with: model.imageURL)
        dateLabel.text = model.date
        setIsLiked(model.isLiked)
    }
}

