//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 23/10/2024.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private var isFetchingProfile = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            // Если есть токен, загружаем профиль
            fetchProfile(token)
        } else {
            // Если токена нет, переходим на экран авторизации
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func fetchProfile(_ token: String) {
        guard !isFetchingProfile else { return }
        isFetchingProfile = true
        
        // Показываем индикатор загрузки
        UIBlockingProgressHUD.show()
        
        // Загружаем профиль
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                // Если успешно, переходим на TabBarController
                self.switchToTabBarController()
            case .failure(let error):
                // Показываем ошибку
                self.showAlert(with: "Ошибка", message: error.localizedDescription)
            }
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр окна приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        // Загружаем TabBarController из сториборда
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        
        tabBarController.profileService = ProfileService.shared
        // Устанавливаем rootViewController
        window.rootViewController = tabBarController
    }
    
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            // После успешной авторизации получаем токен
            guard let token = self.storage.token else {
                self.showAlert(with: "Ошибка", message: "Не удалось получить токен")
                return
            }
            // Загружаем профиль
            self.fetchProfile(token)
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            
            // Устанавливаем делегат
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
