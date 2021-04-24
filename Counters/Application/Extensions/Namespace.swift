import Foundation

/*
 Namespace for the Counters app.
 Provides an easy way to add and review stuff without name collissions
 with the system provided APIs.

 Way to use (class methods):
 ```
 extension CountersNamespace where Base: UIColor {
     static var someCoolBlueColor: UIColor { UIColor.blue }
 }

 view.backgroundColor = UIColor.counters.someCoolBlueColor
 ```

 Way to use (instance methods):
 ```
 extension CountersNamespace where Base: UIColor {
    func withAlpha(_ alpha: CGFloat) -> UIColor {
        self.withAlphaComponent(alpha)
    }
 }
 
 let someColor = UIColor.blue
 view.backgroundColor = someColor.counters.withAlpha(0.5)
 ```
 */


public final class CountersNamespace<Base> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }
}

public protocol CountersNamespaceConvertible {}

extension CountersNamespaceConvertible {
    public static var counters: CountersNamespace<Self>.Type {
        CountersNamespace<Self>.self
    }

    public var counters: CountersNamespace<Self> {
        CountersNamespace(self)
    }
}

extension NSObject: CountersNamespaceConvertible {}
