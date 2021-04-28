import Foundation

final class AddItemViewControllerUseCase {

    typealias ResponseType = (Items?, SwiftNetworkingError?) -> Void

    private enum Endpoint: String {
        case save = "v1/counter"
    }

    private let networking: SwiftNetworking

    // MARK: - Initialization

    init(networking: SwiftNetworking) {
        self.networking = networking
    }

    // MARK: - Use Cases

    func saveItem(name: String, completion: @escaping ResponseType) {
        let url: Endpoint = .save

        let parameters: [String: String] = [
            "title": name
        ]

        networking.post(url: url.rawValue, parameters: parameters, resultType: Items.self) { response, error in
            guard error == nil else {
                completion(nil, error as? SwiftNetworkingError)
                return
            }

            completion(response, nil)
        }
    }
}
