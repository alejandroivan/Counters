import UIKit

public enum ColorName: String, CaseIterable {
    case accent = "AccentColor"
    case background = "Background"
    case buttonText = "ButtonText"
    case descriptionText = "descriptionText"
    case disabledText = "DisabledText"
    case green = "Green"
    case primaryText = "PrimaryText"
    case red = "Red"
    case secondaryText = "SecondaryText"
    case subtitleText = "SubtitleText"
    case yellow = "Yellow"

    /// Get a named color
    public var color: UIColor {
        guard let color = UIColor(named: rawValue) else {
            assertionFailure("Color named '\(rawValue)' not found.")
            return .black
        }
        return color
    }
}

extension CountersNamespace where Base: UIColor {
    public static var accent: UIColor { ColorName.accent.color }
    public static var background: UIColor { ColorName.background.color }
    public static var buttonText: UIColor { ColorName.buttonText.color }
    public static var descriptionText: UIColor { ColorName.descriptionText.color }
    public static var disabledText: UIColor { ColorName.disabledText.color }
    public static var green: UIColor { ColorName.green.color }
    public static var primaryText: UIColor { ColorName.primaryText.color }
    public static var red: UIColor { ColorName.red.color }
    public static var secondaryText: UIColor { ColorName.secondaryText.color }
    public static var subtitleText: UIColor { ColorName.subtitleText.color }
    public static var yellow: UIColor { ColorName.yellow.color }
}
