import UIKit

public protocol ReusableIdentifier: NSObject {
    static var reuseIdentifier: String { get }
}

public extension ReusableIdentifier {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionReusableView: ReusableIdentifier {}
extension UITableViewCell: ReusableIdentifier {}
extension UITableViewHeaderFooterView: ReusableIdentifier {}
