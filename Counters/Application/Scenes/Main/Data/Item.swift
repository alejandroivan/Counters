import Foundation

typealias Items = [Item]

struct Item: Decodable {
    let category: ItemCategory
    let title: String
    var count: Int
}
