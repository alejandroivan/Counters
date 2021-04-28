import Foundation

enum SwiftNetworkingError: Error {
    case notDecodable
    case noConnection
}

/// Just a middle layer between Objective-C networking and Swift calls.

class SwiftNetworking {

    private static let networking: Networking = Networking()

    // MARK: - HTTP Method helpers

    func get<T: Decodable>(
        url: String,
        parameters parametersDictionary: [String: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        let parameters: [URLQueryItem] = parametersDictionary.map { URLQueryItem(name: $0, value: $1) }
        guard let nsArrayParameters = NSArray(array: parameters) as? [URLQueryItem] else {
            return
        }

        Self.networking.getURL(url, parameters: nsArrayParameters) { data, error in
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
        parameters parametersDictionary: [String: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        let parameters: [URLQueryItem] = parametersDictionary.map { URLQueryItem(name: $0, value: $1) }
        guard let nsArrayParameters = NSArray(array: parameters) as? [URLQueryItem] else {
            return
        }

        Self.networking.postURL(url, parameters: nsArrayParameters) { data, error in
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
