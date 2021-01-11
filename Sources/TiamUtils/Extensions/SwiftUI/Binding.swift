import SwiftUI

@available(iOS 13.0, *)
public extension Binding {
    /// A `Binding` wrapper that calls a handler just after the wrapped value is set
    /// - Parameter handler: a callback with this signature: `(newValue, oldValue) -> Void`
    /// - Note: cannot be combined with the `willSet(_:)` Binding wrapper
    func didSet(_ handler: @escaping (Value, Value)->Void) -> Binding<Value> {
        return Binding(get: { self.wrappedValue }, set: { newValue in
            let oldValue = self.wrappedValue
            self.wrappedValue = newValue
            handler(newValue, oldValue)
        })
    }

    /// A `Binding` wrapper that calls a handler just before the wrapped value is set
    /// - Parameter handler: a callback with this signature: `(newValue, oldValue) -> Void`
    /// - Note: cannot be combined with the `didSet(_:)` Binding wrapper
    func willSet(_ handler: @escaping (Value, Value)->Void) -> Binding<Value> {
        return Binding(get: { self.wrappedValue }, set: { newValue in
            let oldValue = self.wrappedValue
            handler(newValue, oldValue)
            self.wrappedValue = newValue
        })
    }
}
