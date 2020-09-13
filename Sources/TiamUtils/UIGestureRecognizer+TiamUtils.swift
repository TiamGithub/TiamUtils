import UIKit

public extension UIGestureRecognizer {
    func cancel() {
        guard isEnabled && (state == .began || state == .changed) else { return }
        isEnabled = false
        assert(state == .cancelled)
        isEnabled = true
    }
}

