import UIKit

/// Common interface to NSLayoutAnchor subclasses
public protocol Anchor: NSObject {
    associatedtype AnchorT: NSObject
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorT>, constant c: CGFloat) -> NSLayoutConstraint
    func constraint(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorT>, constant c: CGFloat) -> NSLayoutConstraint
    func constraint(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorT>, constant c: CGFloat) -> NSLayoutConstraint
}
extension NSLayoutDimension: Anchor { }
extension NSLayoutXAxisAnchor: Anchor { }
extension NSLayoutYAxisAnchor: Anchor { }



/// Common interface to UIView and UILayoutGuide
public protocol AnchorProvider: NSObject {

    var leadingAnchor:  NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor:     NSLayoutXAxisAnchor { get }
    var rightAnchor:    NSLayoutXAxisAnchor { get }
    var centerXAnchor:  NSLayoutXAxisAnchor { get }
    var topAnchor:      NSLayoutYAxisAnchor { get }
    var bottomAnchor:   NSLayoutYAxisAnchor { get }
    var centerYAnchor:  NSLayoutYAxisAnchor { get }
    var widthAnchor:    NSLayoutDimension   { get }
    var heightAnchor:   NSLayoutDimension   { get }

    /// A key path to one of the provider's anchors
    typealias AnchorKeyPath<A: Anchor> = KeyPath<AnchorProvider, A>
}
extension UILayoutGuide: AnchorProvider { }
extension UIView: AnchorProvider { }

public extension AnchorProvider {
    /// Create a `relation` constraint between `self` and `other` for their respective anchor at `keyPath`
    func constraint<A>(
        _ keyPath: AnchorKeyPath<A>,
        relation: NSLayoutConstraint.Relation = .equal,
        to other: AnchorProvider,
        constant: CGFloat = 0)
    -> NSLayoutConstraint {
        let anchor1 = self.nsLayoutAnchor(from: keyPath)
        let anchor2 = other.nsLayoutAnchor(from: keyPath)
        switch relation {
        case .equal:
            return anchor1.constraint(equalTo: anchor2, constant: constant)
        case .greaterThanOrEqual:
            return anchor1.constraint(greaterThanOrEqualTo: anchor2, constant: constant)
        case .lessThanOrEqual:
            return anchor1.constraint(lessThanOrEqualTo: anchor2, constant: constant)
        @unknown default:
            fatalError("Unknown constraint relation")
        }
    }

    /// Convenience method to create 2+ constraints at once for a given anchor type `A` (i.e. X axis, or  Y axis, or dimension)
    /// - Parameters:
    ///   - anchors: 2 (or more)  anchor key-apth
    ///   - relation: =, or ≥ , or ≤
    ///   - other: a view or layout guide
    func constraints<A>(
        _ anchors: AnchorKeyPath<A>... ,
        constant: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        to other: AnchorProvider)
    -> [NSLayoutConstraint] {
        return anchors.map { keyPath in
            constraint(keyPath, relation: relation, to: other, constant: constant)
        }
    }

    private func nsLayoutAnchor<A>(from keyPath: AnchorKeyPath<A>) -> NSLayoutAnchor<A.AnchorT> {
        guard let layoutAnchor = self[keyPath: keyPath] as? NSLayoutAnchor<A.AnchorT> else {
            fatalError("Anchor isn't a valid NSLayoutAnchor subclass --- \(self[keyPath: keyPath])")
        }
        return layoutAnchor
    }
}
