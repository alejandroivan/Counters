import Foundation

enum ItemCategory: String, Decodable {
    case drink = "CATEGORY_DRINK"
    case food = "CATEGORY_FOOD"
    case misc = "CATEGORY_MISC"
}

extension ItemCategory {

    private static let pluralizedSuffix = "_LOCALIZED"

    /// Implement a case when the pluralized word differs from the actual noun.
    /// This is done because not all words are pluralized by just adding a "s"
    /// at the end. Any case not covered will be taken to the default case
    /// (i.e. "do not add anything, just return the localized string for the
    /// identifier and not the pluralized one").
    /// Example: "box" pluralizes to "boxes", not "boxs".

    var pluralized: String {
        let localizableKey = rawValue + Self.pluralizedSuffix
        let localizedString = localizableKey.localized

        guard localizableKey != localizedString else { return rawValue.localized }
        return localizedString
    }
}
