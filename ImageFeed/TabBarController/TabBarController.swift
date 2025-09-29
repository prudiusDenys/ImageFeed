import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }

    // MARK: - Private Methods

    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        // Экран списка изображений
        let imagesListVC = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        imagesListVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )

        // Экран профиля
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )

        // Устанавливаем контроллеры
        viewControllers = [imagesListVC, profileVC]
    }
}
