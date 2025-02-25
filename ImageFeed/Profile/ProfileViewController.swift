import UIKit
import Foundation
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar(with urlString: String)
    func updateProfile(with profile: Profile)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
   //private var presenter: ProfilePresenterProtocol = ProfilePresenter()
    var profileService = ProfileService.shared
    var presenter: ProfilePresenterProtocol?
       
     /*  init(presenter: ProfilePresenterProtocol) {
           self.presenter = presenter
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")*/
    
    func configure(_ presenter: ProfilePresenterProtocol) {
            self.presenter = presenter
        self.presenter?.view = self
        }
   
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "YP Gray")
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textAlignment = .left
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 23, weight: .bold),
            .kern: -0.078
        ]
        
        label.attributedText = NSAttributedString(string: "Екатерина Новикова", attributes: attributes)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont.systemFont( ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "YP White")
        
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = UIColor(named: "YP Red")
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setupLayout()
        //fetchProfileData()
        //avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        assert(presenter != nil, "ProfilePresenter не был сконфигурирован")
        presenter?.viewDidLoad()
    }
    
   /*/ override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = UIBezierPath(roundedRect: avatarImageView.bounds,
                                byRoundingCorners: [.topLeft],
                                cornerRadii: CGSize(width: 61, height: 61))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        avatarImageView.layer.mask = mask
    }*/
    // MARK: - Initializers
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
   
    
    // MARK: - Notification Observers
    
    func updateProfile(with profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No bio available"
    }
    
      private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    
    @objc private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success:
                print("Аватарка успешно обновлена!")
            case .failure(let error):
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                
                print("Получено уведомление об обновлении аватарки:", notification.userInfo ?? "пустой userInfo")
            }
        }
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    private func setupLayout() {
        view.addSubview(avatarImageView)
        view.addSubview(loginNameLabel)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            // Avatar ImageView
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Login Name Label
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Logout Button
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 99),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    private func showLogoutAlert() {
        ProfileLogoutService.shared.showLogoutAlert(from: self)
    }
    
    /*private func fetchProfileData() {
        guard let token = OAuth2TokenStorage().token else {
            print("Ошибка: токен отсутствует")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.updateProfileUI(with: profile)
                    
                    // После успешной загрузки профиля запрашиваем URL аватарки
                    self?.fetchProfileImageURL(for: profile.username)
                    
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }*/
    
    
    private func updateProfileUI(with profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No bio available"
        
        if let avatarURL = ProfileImageService.shared.avatarURL {
            updateAvatar(with: avatarURL)
        }
    }
    
    
    private func fetchProfileImageURL(for username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageURL):
                    self?.updateAvatar(with: imageURL)
                case .failure(let error):
                    print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    internal func updateAvatar(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.3)), .cacheOriginalImage]
        )
    }
}

