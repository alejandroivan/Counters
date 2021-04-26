import Foundation

/// Just a middle layer between Objective-C networking and Swift calls.

class SwiftNetworking {

    enum SwiftNetworkingError: Error {
        case notDecodable
        case noConnection
    }

    private static let networking: Networking = Networking()

    static func get<T: Decodable>(
        url: String,
        parameters parametersDictionary: [String: String],
        resultType: T.Type,
        completion: @escaping (T?, Error?) -> Void
    ) {
        let parameters: [URLQueryItem] = parametersDictionary.map { URLQueryItem(name: $0, value: $1) }
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

            if let result = decodeNetworkObject(data: data, to: T.self) {
                completion(result, nil)
            } else {
                let error: SwiftNetworkingError = .notDecodable
                completion(nil, error)
            }
        }
    }

    private static func decodeNetworkObject<T: Decodable>(data: Data, to _: T.Type) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
