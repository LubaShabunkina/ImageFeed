//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 08/09/2024.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var Label: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
}
