import UIKit

public extension UIViewController {
    /// Returns the frontmost presented UIViewController
    /// - Note: Only valid for single window apps without a `UISceneDelegate`
    static var topPresentedController: UIViewController? {
        var topController = UIApplication.shared.delegate?.window??.rootViewController

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
