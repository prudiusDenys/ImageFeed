import UIKit

final class ProfileViewController: UIViewController {
    lazy var userName = UILabel()
    lazy var email = UILabel()
    lazy var text = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderContent()
    }
    
    private func renderContent() {
        let profileImage = UIImage(named: "avatar")
        let profileImageView = UIImageView(image: profileImage)
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logoutIcon"), for: .normal)
        button.addTarget(self, action: #selector(Self.didTapButton), for: .touchUpInside)
        
        userName.text = "Екатерина Новикова"
        userName.textColor = UIColor(named: "YP White")
        userName.font = UIFont.systemFont(ofSize: 23, weight: .medium)
        
        email.text = "@ekaterina_nov"
        email.textColor = UIColor(named: "YP Gray")
        email.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        text.text = "Hello, world!"
        text.textColor = UIColor(named: "YP White")
        text.font = UIFont.systemFont(ofSize: 13, weight: .regular)

        
        let horizontalStackView = UIStackView(arrangedSubviews: [profileImageView, button])
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(horizontalStackView)
        
        let verticalStackView = UIStackView(arrangedSubviews: [userName, email, text])
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStackView)

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true

        button.contentHorizontalAlignment = .trailing
        button.contentVerticalAlignment = .center
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.alignment = .center
        
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.spacing = 8
             
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            verticalStackView.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 8),
            verticalStackView.leadingAnchor.constraint(equalTo: horizontalStackView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: horizontalStackView.trailingAnchor),
        ])
    }
    
    @objc
    private func didTapButton() {
    }
    
}
