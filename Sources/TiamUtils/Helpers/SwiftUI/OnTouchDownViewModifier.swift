import SwiftUI

@available(iOS 13.0, *)
public extension View {
    func onTouchDownGesture(perform action: @escaping () -> Void) -> some View {
        return self.modifier(OnTouchDownViewModifier(action: action))
    }
}

@available(iOS 13.0, *)
struct OnTouchDownViewModifier: ViewModifier {
    let action: () -> Void
    @GestureState private var hasTouched = false

    func body(content: Content) -> some View {
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !hasTouched {
                    action()
                }
            }
            // `body` closure is called during View updates where changing View state is undefined behavior
            .updating($hasTouched, body: { _, hasTouchedState, _ in
                hasTouchedState = true
            })

        return content
            .simultaneousGesture(dragGesture)
    }
}

