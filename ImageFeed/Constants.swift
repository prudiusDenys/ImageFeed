import Foundation

enum Constants {
    static let accessKey = "s_g949JJedpXlkQRhKKPygVk80ZFHMSAXfQw3S1a37I"
    static let secretKey = "Q3OhDUEBr9Wr29W5VhzSfqpei1Q8XtTCtEsg0sDD9wg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL("https://api.unsplash.com") else {
            fatalError("invalid base URL")
        }
        return url
    }()
}
