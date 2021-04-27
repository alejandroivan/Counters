import Foundation

public extension String {
    var localized: Self {
        localized(self)
    }

    func localized(_ comment: String = GlobalConstants.empty) -> Self {
        NSLocalizedString(self, comment: comment)
    }
}

// MARK: Pluralization

public extension String {
    private static let pluralizedSuffix = "_PLURALIZED"

    /// Implement a case when the pluralized word differs from the actual noun.
    /// This is done because not all words are pluralized by just adding a "s"
    /// at the end. Any case not covered will be taken to the default case
    /// (i.e. "do not add anything, just return the localized string for the
    /// identifier and not the pluralized one").
    /// Example: "box" pluralizes to "boxes", not "boxs".

    var pluralized: String {
        let localizableKey = self + Self.pluralizedSuffix
        let localizedString = localizableKey.localized

        guard localizableKey != localizedString else { return localized }
        return localizedString
    }
}
