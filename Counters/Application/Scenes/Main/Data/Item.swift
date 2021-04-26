import Foundation

typealias Items = [Item]

struct Item: Decodable {
    let title: String
    var count: Int

    init(
        title: String,
        count: Int
    ) {
        self.title = title
        self.count = count
    }
}
