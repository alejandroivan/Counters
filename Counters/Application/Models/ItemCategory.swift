import Foundation

enum ItemCategory: String, Decodable {
    case drink = "CATEGORY_DRINK"
    case food = "CATEGORY_FOOD"
    case misc = "CATEGORY_MISC"
}

extension ItemCategory {

    /// Convenience property for calling `.drink.localized` instead of `.drink.rawValue.localized`.
    var localized: String { rawValue.localized }

    /// Convenience property for calling `.drink.pluralized` instead of `.drink.rawValue.pluralized`
    var pluralized: String { rawValue.pluralized }
}
