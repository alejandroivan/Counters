import UIKit

public protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    public static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: Reusable {}

extension UITableView {
    public func dequeueReusable<T: Reusable>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UICollectionView: Reusable {
    public func dequeueReusable<T: Reusable>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
