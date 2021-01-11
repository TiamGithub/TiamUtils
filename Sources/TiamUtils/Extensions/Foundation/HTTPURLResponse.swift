import Foundation

public extension HTTPURLResponse {
    /// Represents an error returned by a failed http request
    struct ServerError: LocalizedError {
        public let statusCode: Int

        public var errorDescription: String? {
            HTTPURLResponse.localizedString(forStatusCode: self.statusCode)
        }
    }

    var serverError: ServerError? {
        if (200...299).contains(statusCode) {
            return nil
        }
        return ServerError(statusCode: statusCode)
    }
}
