import Foundation

public enum LocalCacheDiffType: String, Codable {
    case increment
    case decrement
    case delete
}

public struct LocalCacheDiff: Codable {
    let identifier: String
    let diffType: LocalCacheDiffType
    let uuid: String

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case diffType = "type"
        case uuid
    }
}
