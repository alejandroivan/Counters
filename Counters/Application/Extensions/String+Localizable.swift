import Foundation

public extension String {
    var localized: Self {
        localized(self)
    }

    func localized(_ comment: String = GlobalConstants.empty) -> Self {
        NSLocalizedString(self, comment: comment)
    }
}
