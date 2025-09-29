
import Foundation

// MARK: - Ошибки сервиса

enum AuthServiceError: Error {
    case invalidRequest
}

// MARK: - OAuth2Service

final class OAuth2Service {
    
    // MARK: Singleton

    static let shared = OAuth2Service()
    private init() {}

    // MARK: - Dependencies

    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared

    // MARK: - Properties

    private var task: URLSessionTask?
    private var lastCode: String?

    private(set) var authToken: String? {
        get { dataStorage.token }
        set { dataStorage.token = newValue }
    }

    // MARK: - Public Methods

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }

                switch result {
                case .success(let body):
                    self.authToken = body.accessToken
                    completion(.success(body.accessToken))

                case .failure(let error):
                    print("[OAuth2Service:fetchOAuthToken] ❌ Ошибка: \(error.localizedDescription)")
                    completion(.failure(error))
                }

                self.task = nil
                self.lastCode = nil
            }
        }

        self.task = task
        task.resume()
    }

    // MARK: - Private Methods

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Invalid token URL")
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

// MARK: - Дополнительный сетевой клиент (не используется)

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
