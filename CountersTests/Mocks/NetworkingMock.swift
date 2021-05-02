import Foundation
@testable import Counters

/// The `urlString` parameter will be used to choose one of the JSON mocks
/// available in the Mocks group. For example, if you use the value
/// `"GET_counters_200"` as the `urlString`, the response will be the data
/// for the contents of the GET_counters_200.json file.
///
/// When the path asked is a real path (like `/api/v1/counters`), all slashes ("`/`")
/// will be replaced with a number sign ("`#`"), so that URL would be translated to
/// `#api#v1#counters`, and its mock file would be `#api#v1#counters.json`.

final class NetworkingMock: Networking {

    var jsonRequestCalled = false
    var getUrlCalled = false
    var postUrlCalled = false
    var deleteUrlCalled = false

    var shouldFail = false

    override func jsonRequest(
        _ url: URL,
        httpMethod method: String,
        parameters: [String : String],
        completionHandler completion: @escaping JSONCompletionHandler
    ) -> URLSessionTask {
        jsonRequestCalled = true
        return super.jsonRequest(url, httpMethod: method, parameters: parameters, completionHandler: completion)
    }

    override func getURL(
        _ urlString: String,
        parameters queryItem: [URLQueryItem]?,
        completionHandler completion: @escaping DataCompletionHandler
    ) {
        getUrlCalled = true

        if shouldFail {
            completion(nil, Self.mockError)
        } else {
            let data = mockData(resource: urlString)
            completion(data, nil)
        }
    }

    override func postURL(
        _ urlString: String,
        parameters queryItems: [URLQueryItem]?,
        completionHandler completion: @escaping DataCompletionHandler
    ) {
        postUrlCalled = true

        if shouldFail {
            completion(nil, Self.mockError)
        } else {
            let data = mockData(resource: urlString)
            completion(data, nil)
        }
    }

    override func deleteURL(
        _ urlString: String,
        parameters queryItem: [URLQueryItem]?,
        completionHandler completion: @escaping DataCompletionHandler
    ) {
        deleteUrlCalled = true

        if shouldFail {
            completion(nil, Self.mockError)
        } else {
            let data = mockData(resource: urlString)
            completion(data, nil)
        }
    }
}

// MARK: - Helpers

extension NetworkingMock {

    private static let mockError = NSError(
        domain: CountersErrorDomain,
        code: CountersErrorCode.noData.rawValue,
        userInfo: nil
    )

    private func mockData(resource: String) -> Data? {
        let testBundle = Bundle(for: Self.self)
        guard let path = testBundle.path(
                forResource: resource.replacingOccurrences(of: "/", with: "#"),
                ofType: "json"
        ) else { return nil }
        let fileUrl = URL(fileURLWithPath: path)
        return try? Data(contentsOf: fileUrl)
    }
}
