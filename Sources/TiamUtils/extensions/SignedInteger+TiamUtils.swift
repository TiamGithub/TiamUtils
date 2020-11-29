import Foundation

public extension SignedInteger {
    /// Returns the next integer value contained in the provided `range` in a circular way (ie. loops back when highest value is reached)
    /// - Note: Will return `range.lowerBound` if the next integer is outisde `range`
    func next(in range: ClosedRange<Self>) -> Self {
        if self >= range.upperBound || self < range.lowerBound {
            return range.lowerBound
        }
        return self + 1
    }

    /// Returns the previous integer value contained in the provided `range` in a circular way (ie. loops back when lowest value is reached)
    /// - Note: Will return `range.upperBound` if the previous integer is outisde `range`
    func previous(in range: ClosedRange<Self>) -> Self {
        if self <= range.lowerBound || self > range.upperBound {
            return range.upperBound
        }
        return self - 1
    }
}
