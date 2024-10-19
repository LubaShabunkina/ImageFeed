//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit

final class AuthViewController: UIViewController {

    @IBAction func loginButoonTapped(_ sender: UIButton) {
        //performSegue(withIdentifier: "ShowWebView", sender: nil)
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            configureBackButton()  // Вызов метода настройки кнопки "Назад"
            
            func configureBackButton() {
                navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
                navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
                navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack") // 4
            }
        }
}
