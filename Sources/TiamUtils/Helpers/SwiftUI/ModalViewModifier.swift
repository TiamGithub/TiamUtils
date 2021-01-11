import SwiftUI

@available(iOS 14.0, *)
/// A SwiftUI wrapper for standard `UIViewController` modal presentations
public struct ModalViewModifier<ModalContent: View>: ViewModifier {
    public init(
        isPresented: Binding<Bool>,
        presentationStyle: UIModalPresentationStyle,
        transitionStyle: UIModalTransitionStyle,
        modalContent: @escaping () -> ModalContent)
    {
        self._isPresented = isPresented
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.modalContent = modalContent
    }

    private let presentationStyle: UIModalPresentationStyle
    private let transitionStyle: UIModalTransitionStyle
    private let modalContent: () -> ModalContent
    @Binding private var isPresented: Bool
    @State private var vc: UIViewController? = nil
    
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
                    vc?.dismiss(animated: true)
                    vc = nil
                }
            }
    }
}
