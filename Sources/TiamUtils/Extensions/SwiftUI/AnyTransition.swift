import SwiftUI

@available(iOS 13.0, *)
public extension AnyTransition {
    /// Inverse transition to `AnyTransition.slide`
    static let slideBackward = Self.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
}
