//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 08/12/2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profileNavController = viewControllers?.first as? UINavigationController,
           let profileVC = profileNavController.topViewController as? ProfileViewController {
            profileVC.profileService = ProfileService.shared 
        }
    }
}
