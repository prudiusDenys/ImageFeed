
import UIKit

// MARK: - Constants

private enum SegueID {
    static let showAuth = "ShowAuthenticationScreen"
}

private enum StoryboardID {
    static let main = "Main"
    static let tabbar = "TabBarViewController"
}

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    // MARK: - Dependencies

    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private var imageView: UIImageView!

    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupImageView()

        if let token = storage.token {
            switchToTabBarController()
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Private
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "splashScreenLogo")

        imageView = UIImageView(image: imageSplashScreenLogo)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: StoryboardID.main, bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: StoryboardID.main, bundle: .main)
            .instantiateViewController(withIdentifier: StoryboardID.tabbar)
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()

            case let .failure(error):
                print(error)
                break
            }
        }
    }
}

// MARK: - Extensions

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        switchToTabBarController()
    }
}
