import SwiftUI

@available(iOS 14.0, *)
public extension View {
    /// Presents a modal popup when a given condition is true.
    /// - Parameters:
    ///   - isPresented: A binding to whether the sheet is presented
    ///   - isDiscardable: If `true`, a tep on the background will dismiss the popup
    ///   - backgroundStyle: A style for the popup's background
    ///   - popupContent: A closure returning the content of the sheet.
    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        isDiscardable: Bool = true,
        backgroundStyle: PopupBackgroundStyle? = .blur(.dark),
        @ViewBuilder popupContent: @escaping () -> PopupContent)
    -> some View {
        self.modifier(ModalViewModifier(isPresented: isPresented, presentationStyle: .overFullScreen, transitionStyle: .crossDissolve) {
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
        RoundedRectangle(cornerRadius: 5)
            .fill(Color(.secondarySystemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(.tertiarySystemBackground), lineWidth: 1)
            )
            .shadow(color: Color(white: 0, opacity: 0.9), radius: 15)
    }
}
