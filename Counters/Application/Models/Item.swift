import Foundation

typealias Items = [Item]

struct Item: Decodable, Equatable {
    let identifier: String
    let title: String
    var count: Int

    init(
        identifier: String,
        title: String,
        count: Int
    ) {
        self.identifier = identifier
        self.title = title
        self.count = count
    }

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case count
    }
}
