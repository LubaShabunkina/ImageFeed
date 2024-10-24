//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    
    @IBAction func loginButoonTapped(_ sender: UIButton) {
        
        oauth2Service.fetchAuthCode(from: self) { [weak self] result in
                switch result {
                case .success(let code):
                    // Получили код — запрашиваем токен
                    guard let self = self else { return }
                    self.oauth2Service.fetchAuthCode(from: self) { result in
                        switch result {
                        case .success(let token):
                            print("Token received: \(token)")
                            self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                        case .failure(let error):
                            print("Failed to fetch token: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
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

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
        self.oauth2Service.fetchToken(with: code) { result in
                switch result {
                case .success(let token):
                    print("Token received: \(token)")
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)")
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}

