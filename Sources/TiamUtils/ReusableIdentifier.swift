import UIKit

public protocol ReusableIdentifier: NSObject {
    static var reuseIdentifier: String { get }
}

public extension ReusableIdentifier {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
