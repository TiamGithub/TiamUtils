import UIKit

public extension UIView {
    func embedSubview(_ subview: UIView, edgeInsets: UIEdgeInsets = .zero) {
        addSubview(subview)
        activateContraintsToGuide(forSubview: subview, insets: edgeInsets)
    }

    func activateContraintsToGuide(_ keyPath: KeyPath<UIView, UILayoutGuide> = \.safeAreaLayoutGuide,
                                   forSubview subview: UIView,
                                   insets: UIEdgeInsets = .zero) {
        let layoutGuide = self[keyPath: keyPath]
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
            subview.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -insets.right),
            subview.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -insets.bottom)])
    }

    func superviews() -> [UIView] {
        var result = [UIView]()
        var currentView = self

        while let sv = currentView.superview {
            result.append(sv)
            currentView = sv
        }

        return result
    }
}
