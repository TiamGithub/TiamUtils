import UIKit

public extension UIView {
    /// Value returned by `intrinsicContentSize`  for views that don't have an intrinsic size
    static let noIntrinsicContentSize = CGSize(width: noIntrinsicMetric, height: noIntrinsicMetric)

    /// Convenience wrapper around `isHidden`
    var isVisible: Bool {
        get {
            return !self.isHidden
        }
        set {
            if newValue != self.isVisible {
                self.isHidden = !newValue
            }
        }
    }

    /// `start`, `middle`, `end` correspond respectively to:
    /// - leading, centre, trainling anchors for the X axis
    /// - top, centre, bottom anchors for the Y axis
    enum PinRelativePosition {
        case start, middle, end
    }

    /// Add `subview` and constrain it to fill the parent's (i.e. `self`) safe area
    /// - Parameters:
    ///   - guideKeyPath: safe areea by default, pass `nil` to force the use of the current view itself
    ///   - edgeInsets: positive values to make the subview smaller inside its parent
    func addFillingSubview(
        _ subview: UIView,
        constrainedToGuide guideKeyPath: KeyPath<UIView, UILayoutGuide>? = \.safeAreaLayoutGuide,
        edgeInsets: UIEdgeInsets = .zero)
    {
        addSubview(subview)
        activateFillingContraints(toGuide: guideKeyPath, forSubview: subview, edgeInsets: edgeInsets)
    }

    /// Add `subview` and constrain it to get pinned at the `pin` position relative the parent's (i.e. `self`) safe area
    /// - Parameters:
    ///   - pin: the relative position
    ///   - guideKeyPath: safe areea by default, pass `nil` to force the use of the current view itself
    ///   - size: for fixed size subviews, use `nil` (default value) to bypass size constraints
    func addPinnedSubview(
        _ subview: UIView,
        pinnedTo pin: (x: PinRelativePosition, y: PinRelativePosition),
        constrainedToGuide guideKeyPath: KeyPath<UIView, UILayoutGuide>? = \.safeAreaLayoutGuide,
        offset: CGPoint = .zero,
        size: CGSize? = nil)
    {
        addSubview(subview)
        activatePinningConstraints(pin, toGuide: guideKeyPath, forSubview: subview, offset: offset, size: size)
    }

    /// Activate `subview` constraints to fill the parent's (i.e. `self`) safe area
    /// - Parameters:
    ///   - guideKeyPath: safe areea by default, pass `nil` to force the use of the current view itself
    ///   - edgeInsets: positive values to make the subview smaller inside its parent
    func activateFillingContraints(
        toGuide guideKeyPath: KeyPath<UIView, UILayoutGuide>? = \.safeAreaLayoutGuide,
        forSubview subview: UIView,
        edgeInsets: UIEdgeInsets = .zero)
    {
        assert(subviews.contains(subview), "Subview must be added to its parent before activating constraints")

        let guide = guideKeyPath.map({ self[keyPath: $0] })
        let destinationAnchorProvider: AnchorProvider = guide ?? self

        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [subview.constraint(\.leadingAnchor, to: destinationAnchorProvider, constant: edgeInsets.left),
             subview.constraint(\.trailingAnchor, to: destinationAnchorProvider, constant: -edgeInsets.right),
             subview.constraint(\.topAnchor, to: destinationAnchorProvider, constant: edgeInsets.top),
             subview.constraint(\.bottomAnchor, to: destinationAnchorProvider, constant: -edgeInsets.bottom)])
    }

    /// Activate `subview` constraints to get pinned at the `pin` position relative the parent's (i.e. `self`) safe area guide
    /// - Parameters:
    ///   - pin: the relative position
    ///   - guideKeyPath: safe areea by default, pass `nil` to force the use of the current view itself
    ///   - size: for fixed size subviews, use `nil` (default value) to bypass size constraints
    func activatePinningConstraints(
        _ pin: (x: PinRelativePosition, y: PinRelativePosition),
        toGuide guideKeyPath: KeyPath<UIView, UILayoutGuide>? = \.safeAreaLayoutGuide,
        forSubview subview: UIView,
        offset: CGPoint = .zero,
        size: CGSize? = nil)
    {
        assert(subviews.contains(subview), "Subview must be added to its parent before activating constraints")

        let guide = guideKeyPath.map({ self[keyPath: $0] })
        let destinationAnchorProvider: AnchorProvider = guide ?? self

        subview.translatesAutoresizingMaskIntoConstraints = false

        let xAnchor: AnchorKeyPath<NSLayoutXAxisAnchor>, yAnchor: AnchorKeyPath<NSLayoutYAxisAnchor>
        switch pin.x {
        case .start: xAnchor = \.leadingAnchor
        case .middle: xAnchor = \.centerXAnchor
        case .end: xAnchor = \.trailingAnchor
        }
        switch pin.y {
        case .start: yAnchor = \.topAnchor
        case .middle: yAnchor = \.centerYAnchor
        case .end: yAnchor = \.bottomAnchor
        }

        let sizeConstraints: [NSLayoutConstraint]
        if let size = size {
            sizeConstraints = [subview.widthAnchor.constraint(equalToConstant: size.width),
                               subview.heightAnchor.constraint(equalToConstant: size.height)]
        } else {
            assert(subview.intrinsicContentSize != UIView.noIntrinsicContentSize)
            sizeConstraints = []
        }

        NSLayoutConstraint.activate(
            [subview.constraint(xAnchor, to: destinationAnchorProvider, constant: offset.x),
             subview.constraint(yAnchor, to: destinationAnchorProvider, constant: offset.y)]
            + sizeConstraints)
    }

    /// Array of all superviews, from direct superview to furthest superview
    func superviews() -> [UIView] {
        var result = [UIView]()
        var currentView = self

        while let sv = currentView.superview {
            result.append(sv)
            currentView = sv
        }

        return result
    }

    /// Prefer reusing a single renderer multiple times if rendering many same-sized images
    func renderToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
