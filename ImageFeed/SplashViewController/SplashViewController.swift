
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

    private let storage = OAuth2TokenStorage()

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: SegueID.showAuth, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueID.showAuth else {
            super.prepare(for: segue, sender: sender)
            return
        }

        let target = (segue.destination as? UINavigationController)?.topViewController ?? segue.destination
        guard let authVC = target as? AuthViewController else {
            assertionFailure("Failed to prepare for \(SegueID.showAuth)")
            return
        }
        authVC.delegate = self
    }

    // MARK: - Private

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: StoryboardID.main, bundle: .main)
            .instantiateViewController(withIdentifier: StoryboardID.tabbar)

        // Плавная смена rootViewController
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}

