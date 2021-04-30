import Foundation

enum SwiftNetworkingError: Error {
    case notDecodable
    case noConnection
}

/// Just a middle layer between Objective-C networking and Swift calls.

class SwiftNetworking {

    private let networking: Networking
    private let reachability: SwiftReachability

    // MARK: - Initialization

    init(
        networking: Networking = Networking(),
        reachability: SwiftReachability = SwiftReachability.default
    ) {
        self.networking = networking
        self.reachability = reachability
    }

    // MARK: - HTTP Method helpers

    func get<T: Decodable>(
        url: String,
        parameters parametersDictionary: [EndpointParameter: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        guard reachability.isNetworkReachable else {
            let error: SwiftNetworkingError = .noConnection
            completion(nil, error)
            return
        }

        let parameters: [URLQueryItem] = parametersDictionary.map { URLQueryItem(name: $0.rawValue, value: $1) }
        guard let nsArrayParameters = NSArray(array: parameters) as? [URLQueryItem] else {
            return
        }

        networking.getURL(url, parameters: nsArrayParameters) { data, error in
            guard
                error == nil,
                let data = data
            else {
                let error: SwiftNetworkingError = .noConnection
                completion(nil, error)
                return
            }

            if let result = Self.decodeNetworkObject(data: data, to: T.self) {
                completion(result, nil)
            } else {
                let error: SwiftNetworkingError = .notDecodable
                completion(nil, error)
            }
        }
    }

    func post<T: Decodable>(
        url: String,
        parameters parametersDictionary: [EndpointParameter: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        guard reachability.isNetworkReachable else {
            let error: SwiftNetworkingError = .noConnection
            completion(nil, error)
            return
        }
        
        let parameters: [URLQueryItem] = parametersDictionary.map { URLQueryItem(name: $0.rawValue, value: $1) }
        guard let nsArrayParameters = NSArray(array: parameters) as? [URLQueryItem] else {
            return
        }

        networking.postURL(url, parameters: nsArrayParameters) { data, error in
            guard
                error == nil,
                let data = data
            else {
                let error: SwiftNetworkingError = .noConnection
                completion(nil, error)
                return
            }

            if let result = Self.decodeNetworkObject(data: data, to: T.self) {
                completion(result, nil)
            } else {
                let error: SwiftNetworkingError = .notDecodable
                completion(nil, error)
            }
        }
    }

    // MARK: - Helpers

    private static func decodeNetworkObject<T: Decodable>(data: Data, to _: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
