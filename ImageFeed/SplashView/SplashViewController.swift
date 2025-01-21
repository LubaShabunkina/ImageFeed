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
    var profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var isFetchingProfile = false
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            // Если есть токен, загружаем профиль
            fetchProfile(token)
        } else {
            // Если токена нет, переходим на экран авторизации
            showAuthViewController()
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
            case .success(let profile):
                // После успешной загрузки профиля вызываем метод для получения аватарки
                self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in
                    // Не ждем завершения запроса, сразу переходим к TabBarController
                    self.switchToTabBarController()
                }
            case .failure(let error):
                // Показываем ошибку
                self.showAlert(with: "Ошибка", message: error.localizedDescription)
            }
        }
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid Configuration")
            }
            
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            
            window.rootViewController = tabBarController
        }
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("AuthViewController not found in storyboard")
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        DispatchQueue.main.async { // Выполняем на главном потоке
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
}

/*extension SplashViewController {
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
}*/
