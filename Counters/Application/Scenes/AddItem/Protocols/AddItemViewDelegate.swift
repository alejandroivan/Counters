import Foundation

/// This protocol communicates AddItemView user actions back to its delegate.
protocol AddItemViewDelegate: class {

    func didPressExamples()
    func progressIndicatorTextField(_ textField: ProgressIndicatorTextField, isAnimating: Bool)
}
