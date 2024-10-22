//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    
    @IBAction func loginButoonTapped(_ sender: UIButton) {
        /*
        oauth2Service.fetchToken(with: code) { result in
            switch result {
            case .success(let token):
                print("Token received: \(token)")
                // Обработайте успешную авторизацию
            case .failure(let error):
                print("Failed to fetch token: \(error)")
                // Обработайте ошибку
            }
        } */
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            configureBackButton()
        }
        
        private func configureBackButton() {
            navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
            navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
        }
    }
    
