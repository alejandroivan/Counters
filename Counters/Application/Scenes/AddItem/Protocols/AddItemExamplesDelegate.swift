import Foundation

/// This protocol communicates the examples view controller with a delegate,
/// which will be informed of that element the user selected.

protocol AddItemExamplesDelegate: class {

    func userDidChooseExample(title: String)
}
