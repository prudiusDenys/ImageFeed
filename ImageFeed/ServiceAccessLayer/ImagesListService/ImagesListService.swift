import Foundation

let PAGE_SIZE = 10

final class ImagesListService {
    // MARK: Singleton
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private properties
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private var lastLoadedPage: Int = 0
    private(set) var photos: [Photo] = []
    
    // MARK: - Public Methods
    
    // функция для получения очередной страницы
    func fetchPhotosNextPage(completion: @escaping (Result<Photo, Error>) -> Void) {
        if task != nil {
            print("Загрузка уже идет")
            return
        }

        let nextPage = lastLoadedPage + 1
        
        guard let request = makePhotosRequest(page: nextPage, with: PAGE_SIZE) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let convertedPhotoResults = photoResults.map(convert)
                let uniquePhotoResults = convertedPhotoResults.filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }

                    self.photos.append(contentsOf: uniquePhotoResults)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }
            case .failure(let error):
                print("[ImagesListService]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func convert(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        let createdAtDate: Date? = {
            guard let createdAt = result.createdAt else { return nil }
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: createdAt)
        }()

        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAtDate,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.small,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser ?? false
        )
    }
    
    private func makePhotosRequest(page: Int, with pageSize: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(url: Constants.defaultBaseURL, resolvingAgainstBaseURL: false) else { return nil }
        
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "order_by", value: "latest"),
            URLQueryItem(name: "per_page", value: String(pageSize)),
        ]

        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
