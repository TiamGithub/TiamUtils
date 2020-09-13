import UIKit

public extension UIViewController {
    func embedChild(_ childVC: UIViewController, inside containerView: UIView? = nil, edgeInsets: UIEdgeInsets = .zero) {
        let containerView: UIView = containerView ?? self.view
        self.addChild(childVC)
        containerView.embedSubview(childVC.view, edgeInsets: edgeInsets)
        childVC.didMove(toParent: self)
    }

    func unembedChild(_ childVC: UIViewController) {
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }

    func animateTransition(from child1: UIViewController, to child2: UIViewController, inView containerView: UIView,
                           duration: TimeInterval = 0.3, options: UIView.AnimationOptions) {
        child1.willMove(toParent: nil)
        self.addChild(child2)

        self.transition(from: child1, to: child2, duration: duration, options: options, animations: {
            containerView.activateContraintsToGuide(forSubview: child2.view)
        }, completion: { _ in
            child1.removeFromParent()
            child2.didMove(toParent: self)
        })
    }

    /// Only valid for single window apps without a `UISceneDelegate`
    /// - Returns: frontmost presented UIViewController
    static func topPresentedController() -> UIViewController? {
        var topController = UIApplication.shared.delegate?.window??.rootViewController

        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }

        return topController
    }
}

public extension UIPopoverPresentationControllerDelegate where Self: UIViewController {
    func present(_ presentedVC: UIViewController, inPopoverFrom sourceView: UIView, arrowDirections: UIPopoverArrowDirection = .any) {
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
