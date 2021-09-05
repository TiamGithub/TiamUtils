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
    @State private var presentedModalController: UIViewController? = nil
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public func body(content: Content) -> some View {
        return content
            .onChange(of: horizontalSizeClass) { _ in
                guard isPresented else { return }
                dismissModal()
            }
            .onChange(of: verticalSizeClass) { _ in
                guard isPresented else { return }
                dismissModal()
            }
            .onChange(of: isPresented) { [wasPresented = isPresented] isPresentedNewValue in
                if !wasPresented && isPresentedNewValue {
                    let hostingController = UIHostingController(rootView: modalContent())
                    hostingController.modalPresentationStyle = presentationStyle
                    hostingController.modalTransitionStyle = transitionStyle
                    hostingController.view.backgroundColor = .clear
                    presentedModalController = hostingController
                    UIViewController.topPresentedController?.present(hostingController, animated: true)
                } else if wasPresented && !isPresentedNewValue {
                    dismissModal()
                }
            }
    }

    private func dismissModal() {
        guard let topController = UIViewController.topPresentedController,
              let modalController = presentedModalController else {
            return
        }
        guard topController === modalController else {
            /// dismiss children first, then recursively retry dismissing the Modal on completion
            return topController.dismiss(animated: true, completion: dismissModal)
        }
        presentedModalController = nil
        modalController.dismiss(animated: true, completion: onDismiss)
        isPresented = false
    }
}
