import Foundation

public extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }

    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(range.lowerBound, self)
    }

    func clamped(to range: PartialRangeThrough<Self>) -> Self {
        min(self, range.upperBound)
    }
}
