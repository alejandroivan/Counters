import Foundation

enum SwiftNetworkingError: Error {
    case notDecodable
    case noConnection
}

/// Just a middle layer between Objective-C networking and Swift calls.

class SwiftNetworking {

    private enum HTTPParametrizedMethod {
        case post
        case delete
    }

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
        parametrizedMethodRequest(
            url: url,
            method: .post,
            parameters: parametersDictionary,
            resultType: T.self,
            completion: completion
        )
    }

    func delete<T: Decodable>(
        url: String,
        parameters parametersDictionary: [EndpointParameter: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        print("DELETE: \(url)")
        parametrizedMethodRequest(
            url: url,
            method: .delete,
            parameters: parametersDictionary,
            resultType: T.self,
            completion: completion
        )
    }

    // MARK: - Helpers

    private func parametrizedMethodRequest<T: Decodable>(
        url: String,
        method: HTTPParametrizedMethod,
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

        let completionHandler: DataCompletionHandler = { data, error in
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

        switch method {
        case .post: networking.postURL(url, parameters: nsArrayParameters, completionHandler: completionHandler)
        case .delete: networking.deleteURL(url, parameters: nsArrayParameters, completionHandler: completionHandler)
        }
    }

    private static func decodeNetworkObject<T: Decodable>(data: Data, to _: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
