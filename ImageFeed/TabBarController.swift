//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Luba Shabunkina on 08/12/2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 1. Создаем контроллер списка через сториборд
        guard let listsViewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ImagesListViewController else {
            fatalError("Не удалось загрузить ListsViewController")
        }
        
        // 2. Создаем презентер для профиля
        let profilePresenter = ProfilePresenter()

        // 3. Создаем контроллер профиля без сториборда
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profilePresenter.view = profileViewController
        // 4. Добавляем в TabBar
        self.viewControllers = [listsViewController, profileViewController]
        
    }
}
