import UIKit

public extension UIFont {
    /// Returns a bold version of current font
    ///
    /// Usage:
    /// ````
    /// label.font = .preferredFont(forTextStyle: .body).bold()
    /// ````
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    /// Returns a italic version of current font
    ///
    /// Usage:
    /// ````
    /// label.font = .preferredFont(forTextStyle: .body).italic()
    /// ````
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }

    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
