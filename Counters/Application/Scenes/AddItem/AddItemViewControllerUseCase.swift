import Foundation

final class AddItemViewControllerUseCase {

    typealias ResponseType = (Items?, SwiftNetworkingError?) -> Void

    private let networking: SwiftNetworking

    // MARK: - Initialization

    init(networking: SwiftNetworking) {
        self.networking = networking
    }

    // MARK: - Use Cases

    func saveItem(name: String, completion: @escaping ResponseType) {
        let endpoint: Endpoint = .saveItem

        let parameters: [EndpointParameter: String] = [
            .title: name
        ]

        networking.post(url: endpoint.path(), parameters: parameters, resultType: Items.self) { response, error in
            guard error == nil else {
                completion(nil, error as? SwiftNetworkingError)
                return
            }

            completion(response, nil)
        }
    }
}
