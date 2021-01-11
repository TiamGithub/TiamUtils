import UIKit

extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public typealias FloatLiteralType = Float
    public typealias IntegerLiteralType = Int

    public init(floatLiteral value: Self.FloatLiteralType) {
        let clamped = value.clamped(to: 0...1000)
        self.init(clamped)
    }

    public init(integerLiteral value: Self.IntegerLiteralType) {
        let clamped = Float(value.clamped(to: 0...1000))
        self.init(clamped)
    }
}
