import UIKit

public extension UIViewController {
    /// Returns the frontmost presented UIViewController
    /// - Note: Only tested with single window apps without a `UISceneDelegate`
    static var topPresentedController: UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController

        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }

        return topController
    }

    /// Add a child view controller to the current container view controller
    /// - Parameters:
    ///   - childVC: the contained view controller
    ///   - containerView: the view in wich to add add the child view controller's root view. By default the container's root view is used.
    ///   - edgeInsets: edge insets around the child view controller's view.
    func embedChild(_ childVC: UIViewController, inside containerView: UIView? = nil, edgeInsets: UIEdgeInsets = .zero) {
        let containerView: UIView = containerView ?? self.view
        self.addChild(childVC)
        containerView.addFillingSubview(childVC.view, edgeInsets: edgeInsets)
        childVC.didMove(toParent: self)
    }

    /// Remove a child view controller from its parent container controller
    func unembedChild(_ childVC: UIViewController) {
        assert(children.contains(childVC))
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }

    /// Present an error message in a standard alert popup
    func presentAlert(message: String, okText: String = "Ok", completion: (() -> Void)? = nil) {
        let errorAlertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okText, style: .default)
        errorAlertController.addAction(okAction)
        Self.topPresentedController?.present(errorAlertController, animated: true, completion: completion)
    }

    /// Transition between 2 child view controller with a standard animation
    /// - Parameters:
    ///   - child1: the source child view controller to hide and remove
    ///   - child2: the destination child view controller to add and show
    ///   - options: provide a transition animation option (e.g. `transitionFlipFromLeft`)
    func animateTransition(
        from child1: UIViewController,
        to child2: UIViewController,
        duration: TimeInterval = 0.3,
        options: UIView.AnimationOptions,
        completion: ((Bool) -> Void)? = nil)
    {
        assert(children.contains(child1) && !children.contains(child2))
        guard let containerView = child1.view.superview else {
            return
        }

        child1.willMove(toParent: nil)
        addChild(child2)

        transition(from: child1, to: child2, duration: duration, options: options, animations: {
            containerView.addFillingSubview(child2.view)
        }, completion: { result in
            child1.removeFromParent()
            child2.didMove(toParent: self)
            completion?(result)
        })
    }
}

#if DEBUG
import SwiftUI

public extension UIViewController {
    /// Creates a Xcode 11+ preview for the current view controller
    /// ````
    /// #if canImport(SwiftUI) && DEBUG
    /// import SwiftUI
    ///
    /// @available(iOS 13.0, *)
    /// struct VCPreview: PreviewProvider {
    ///     static var previews: some View {
    ///         ViewController(viewModel: ViewModel()).asPreview()
    ///     }
    /// }
    /// #endif
    /// ````
    @available(iOS 13, *)
    func asPreview() -> some View {
        Preview(viewController: self)
    }

    @available(iOS 13, *)
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    }
}
#endif


public extension UIPopoverPresentationControllerDelegate where Self: UIViewController {
    func present(
        _ presentedVC: UIViewController,
        inPopoverFrom sourceView: UIView,
        arrowDirections: UIPopoverArrowDirection = .any)
    {
        assert(self.responds(to: #selector(UIPopoverPresentationControllerDelegate.adaptivePresentationStyle(for:traitCollection:))),
               "Implement \"adaptivePresentationStyle(for:traitCollection:)\" and return \".none\" to support popover in compact environment")
        presentedVC.modalPresentationStyle = .popover
        presentedVC.popoverPresentationController?.delegate = self
        presentedVC.popoverPresentationController?.delegate = self
        presentedVC.popoverPresentationController?.sourceView = sourceView
        presentedVC.popoverPresentationController?.sourceRect = sourceView.bounds
        presentedVC.popoverPresentationController?.permittedArrowDirections = arrowDirections
        self.present(presentedVC, animated: true)
    }
}
