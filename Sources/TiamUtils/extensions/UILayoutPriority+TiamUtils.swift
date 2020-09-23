import UIKit

extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public typealias FloatLiteralType = Float
    public typealias IntegerLiteralType = Int

    public init(floatLiteral value: Self.FloatLiteralType) {
        let clamped = min(1000, max(value, 0))
        self.init(clamped)
    }

    public init(integerLiteral value: Self.IntegerLiteralType) {
        let clamped = Float(min(1000, max(value, 0)))
        self.init(clamped)
    }
}
