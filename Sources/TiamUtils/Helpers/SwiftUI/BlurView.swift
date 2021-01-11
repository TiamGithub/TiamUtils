import SwiftUI

/// A SwiftUI wrapper for `UIVisualEffectView` and `UIBlurEffect`
public struct BlurView: UIViewRepresentable {
    public let style: UIBlurEffect.Style

    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
