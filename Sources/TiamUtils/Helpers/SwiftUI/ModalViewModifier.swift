import SwiftUI

@available(iOS 14.0, *)
/// A SwiftUI wrapper for standard `UIViewController` modal presentations
public struct ModalViewModifier<ModalContent: View>: ViewModifier {
    public init(
        isPresented: Binding<Bool>,
        presentationStyle: UIModalPresentationStyle,
        transitionStyle: UIModalTransitionStyle,
        onDismiss: (() -> Void)? = nil,
        modalContent: @escaping () -> ModalContent)
    {
        self._isPresented = isPresented
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.modalContent = modalContent
        self.onDismiss = onDismiss
    }

    private let presentationStyle: UIModalPresentationStyle
    private let transitionStyle: UIModalTransitionStyle
    private let modalContent: () -> ModalContent
    private let onDismiss: (() -> Void)?
    @Binding private var isPresented: Bool
    @State private var vc: UIViewController? = nil
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public func body(content: Content) -> some View {
        return content
            .onChange(of: isPresented) { isPresentedNewValue in
                if isPresentedNewValue {
                    let ctrl = UIHostingController(rootView: modalContent())
                    ctrl.modalPresentationStyle = presentationStyle
                    ctrl.modalTransitionStyle = transitionStyle
                    ctrl.view.backgroundColor = .clear
                    vc = ctrl
                    UIViewController.topPresentedController?.present(ctrl, animated: true)
                } else {
                    vc?.dismiss(animated: true, completion: onDismiss)
                    vc = nil
                }
            }
            .onChange(of: horizontalSizeClass) { _ in
                isPresented = false
            }
            .onChange(of: verticalSizeClass) { _ in
                isPresented = false
            }
    }
}
