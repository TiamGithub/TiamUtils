import UIKit

public protocol IdentifierReusable: NSObject {
    static var reuseIdentifier: String { get }
}

public extension IdentifierReusable {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionReusableView: IdentifierReusable {}
extension UITableViewCell: IdentifierReusable {}
extension UITableViewHeaderFooterView: IdentifierReusable {}
