
import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}
final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let tokenStorage: OAuth2TokenStorage
    
    init(profileService: ProfileService = .shared,
         profileImageService: ProfileImageService = .shared,
         tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage()) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
    }
    
    func viewDidLoad() {
        fetchProfileData()
    }
    
    private func fetchProfileData() {
        guard let token = tokenStorage.token else {
            print("Ошибка: токен отсутствует")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.view?.updateProfile(with: profile)
                    self?.fetchProfileImageURL(for: profile.username)
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProfileImageURL(for username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    self?.view?.updateAvatar(with: imageURL)
                case .failure(let error):
                    print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didTapLogout() {
        ProfileLogoutService.shared.showLogoutAlert()
    }
}
