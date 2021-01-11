import UIKit

public extension UIEdgeInsets {
    /// UIEdgeInsets with a unique  inset value
    init(_ inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// UIEdgeInsets with a different  value for the x and y axis
    init(x: CGFloat = 0, y: CGFloat = 0) {
        self.init(top: y, left: x, bottom: y, right: x)
    }
}
