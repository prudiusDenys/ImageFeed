import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    private let segueToWebView = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueToWebView else {
            super.prepare(for: segue, sender: sender)
            return
        }

        guard let webVC = segue.destination as? WebViewController else {
            assertionFailure("Expected WebViewController as destination for segue '\(segueToWebView)'")
            return
        }

        webVC.delegate = self
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let result):
                oAuth2TokenStorage.token = result.accessToken
                self.delegate?.didAuthenticate(self)
            case .failure:
                // TODO
                break
            }
        }
    }

    func webViewControllerDidCancel(_ vc: WebViewController) {
        vc.dismiss(animated: true)
    }
}

