import Foundation

final class MainViewControllerUseCase {
    typealias ResponseType = (Items?, SwiftNetworkingError?) -> Void

    private enum Endpoint: String {
        case getItems = "v1/counters"
    }

    private let networking: SwiftNetworking

    // MARK: - Initialization

    init(networking: SwiftNetworking) {
        self.networking = networking
    }

    // MARK: - Use Cases

    func getItems(completion: @escaping ResponseType) {
        let url: Endpoint = .getItems

        networking.get(url: url.rawValue, parameters: [:], resultType: Items.self) { response, error in
            guard error == nil else {
                completion(nil, error as? SwiftNetworkingError)
                return
            }

            completion(response, nil)
        }
    }
}
