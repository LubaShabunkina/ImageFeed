//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit

final class AuthViewController: UIViewController {

    @IBAction func loginButoonTapped(_ sender: UIButton) {
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            configureBackButton()
            
            func configureBackButton() {
                navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
                navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
            }
        }
}
