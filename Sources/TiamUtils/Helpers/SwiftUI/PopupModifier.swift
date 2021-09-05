import SwiftUI

@available(iOS 14.0, *)
public extension View {
    /// Presents a modal popup when a given condition is true.
    /// - Parameters:
    ///   - isPresented: A binding to whether the sheet is presented
    ///   - isDiscardable: If `true`, a tap on the background will dismiss the popup
    ///   - backgroundStyle: A style for the popup's background
    ///   - onDismiss: A closure called after the popup is dismissed
    ///   - popupContent: A closure returning the content of the sheet.
    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        isDiscardable: Bool = true,
        backgroundStyle: PopupBackgroundStyle? = .blur(.dark),
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder popupContent: @escaping () -> PopupContent)
    -> some View {
        self.modifier(ModalViewModifier(isPresented: isPresented, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve, onDismiss: onDismiss) {
            ZStack {
                Group {
                    if let popupBackgroundStyle = backgroundStyle {
                        switch popupBackgroundStyle {
                        case .blur(let blurStyle): BlurView(style: blurStyle)
                        case .opacity(let alpha): Color(white: 0, opacity: alpha)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: isDiscardable ? { isPresented.wrappedValue = false } : {})

                popupContent()
                    .fixedSize()
                    .padding()
                    .background(PopupRectangleView())
            }
        })
    }
}

public enum PopupBackgroundStyle {
    case blur(UIBlurEffect.Style)
    case opacity(Double)
}

@available(iOS 13.0, *)
private struct PopupRectangleView: View {
    var body: some View {
        let roundedRectangle = RoundedRectangle(cornerRadius: 8, style: .continuous)

        roundedRectangle
            .fill(Color(.secondarySystemBackground))
            .overlay(roundedRectangle.stroke(Color(.tertiarySystemBackground)))
            .shadow(color: Color(white: 0, opacity: 0.9), radius: 15)
    }
}
