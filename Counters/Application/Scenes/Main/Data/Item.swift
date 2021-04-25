import Foundation

typealias Items = [Item]

struct Item: Decodable {
    var category: ItemCategory?
    let title: String
    var count: Int

    init(
        category: ItemCategory? = nil,
        title: String,
        count: Int
    ) {
        self.category = category
        self.title = title
        self.count = count
    }
}
