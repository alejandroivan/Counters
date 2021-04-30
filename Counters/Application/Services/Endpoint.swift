import Foundation

// MARK: - Cases

public enum Endpoint: String {

    case saveItem = "counter"
    case getItems = "counters"
}

// MARK: - Constants

public extension Endpoint {
    
    struct Constants {
        public enum Version: String {
            case v1 = "v1"
        }

        static let base = "api"
    }

    /// Calculates the path of the endpoint, without the baseUrl.
    /// Format: /api/{version}/{endpoint_name}
    /// Example: /api/v1/counters
    /// - Parameter version: Version of the api
    /// - Returns: The endpoint path
    func path(for version: Constants.Version = .v1) -> String {
        Self.url(for: self, version: version)
    }

    private static func url(for endpoint: Endpoint, version: Constants.Version = .v1) -> String {
        "/\(Constants.base)/\(version.rawValue)/\(endpoint.rawValue)"
    }
}
