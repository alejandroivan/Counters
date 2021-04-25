import Foundation

protocol AddItemViewDisplay: class {
    var mainNavigationController: MainNavigationController? { get }

    /// Passthrough for the same method in UIViewController
    func dismiss(animated flag: Bool, completion: (() -> Void)?)

    var isSaving: Bool { get set }
}