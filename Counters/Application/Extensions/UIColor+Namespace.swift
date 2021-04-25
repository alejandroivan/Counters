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
    /// Orange. Hex: #FF9500
    public static var accent: UIColor { ColorName.accent.color }
    /// Background white. Hex: #ECECEC
    public static var background: UIColor { ColorName.background.color }
    /// White. Hex: #FFFFFF
    public static var buttonText: UIColor { ColorName.buttonText.color }
    /// Description primary color. Light Mode: #2B2B2B - Dark Mode: #D3D3D3
    public static var descriptionText: UIColor { ColorName.descriptionText.color }
    /// Disabled text gray. Hex: #DCDCDF
    public static var disabledText: UIColor { ColorName.disabledText.color }
    /// Green. Hex: #4BD963
    public static var green: UIColor { ColorName.green.color }
    /// Primary text black. Hex: #000000
    public static var primaryText: UIColor { ColorName.primaryText.color }
    /// Red. Hex: #FF3A2F
    public static var red: UIColor { ColorName.red.color }
    /// Secondary text gray. Hex: #878A90
    public static var secondaryText: UIColor { ColorName.secondaryText.color }
    /// Subtitle text gray. Light Mode: #4A4A4A - Dark Mode: #CBCBCB
    public static var subtitleText: UIColor { ColorName.subtitleText.color }
    /// Yellow. Hex: #FFCC00
    public static var yellow: UIColor { ColorName.yellow.color }
}
