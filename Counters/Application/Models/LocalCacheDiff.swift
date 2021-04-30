import Foundation

public enum LocalCacheDiffType: String, Codable {
    case increment
    case decrement
}

public struct LocalCacheDiff: Codable {
    let identifier: String
    let diffType: LocalCacheDiffType

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case diffType = "type"
    }
}
