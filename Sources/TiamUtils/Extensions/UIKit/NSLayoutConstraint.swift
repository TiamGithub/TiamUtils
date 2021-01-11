import UIKit

public extension NSLayoutConstraint {
    /// Call right after creation and before activation, to give the current constraint a custom priority
    func prioritized(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    /// Convenience method to activate multiple arrays of constraints
    static func activate(_ arrayOfArrays: [NSLayoutConstraint]...) {
        let flattened = arrayOfArrays.flatMap({$0})
        NSLayoutConstraint.activate(flattened)
    }
}
