import SwiftUI

@available(iOS 13.0, *)
public extension View {
    /// Positions this view within an invisible frame having an infinite size
    func greedyFrame(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    /// Modifier that reads the size of the current view’s container without affecting this view’s layout
    /// - Parameter callback: closure called when this iview's size changes
    func geometry(_ callback: @escaping (GeometryProxy) -> ()) -> some View {
        self.geometry(id: 1, callback)
    }

    /// Modifier that reads the size of the current view’s container without affecting this view’s layout
    /// - Parameters:
    ///   - id: A `Hashable` parameter indicating that the size should be recomputed when its value changes
    ///   - callback: closure called when this iview's size changes
    func geometry<T: Hashable>(id: T, _ callback: @escaping (GeometryProxy) -> ()) -> some View {
        self.background(GeometryReader { proxy in
            Color.clear.onAppear {
                callback(proxy)
            }
            .id(id)
        })
    }
}
