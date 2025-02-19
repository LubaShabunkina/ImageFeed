//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 19/10/2024.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    let oauth2Service = OAuth2Service.shared
    
    @IBAction private func loginButoonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showWebView", sender: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
               guard
                   let webViewViewController = segue.destination as? WebViewViewController
               else {
                   assertionFailure("Failed to prepare for \("showWebView")")
                   return
               }
               let webViewPresenter = WebViewPresenter()
               webViewViewController.presenter = webViewPresenter
               webViewPresenter.view = webViewViewController
               webViewViewController.delegate = self
           } else {
               super.prepare(for: segue, sender: sender)
           }
       }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        
        vc.dismiss(animated: true, completion: nil)
    }
    
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            UIBlockingProgressHUD.show()
            self.oauth2Service.fetchToken(with: code) { [weak self] result in
                guard let self = self else { return }
                // Скрываем индикатор после завершения
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let token):
                    print("Token received: \(token)")
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert() // Показать алерт при ошибке
                    }
                }
            }
        }
    }
}
