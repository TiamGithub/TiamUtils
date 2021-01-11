import UIKit

public extension UIButton {
    /// Convenience init to create a button with a title,  an optional image and color, supporting dynamic text size
    convenience init(title: String, color: UIColor = .systemBlue, textStyle: UIFont.TextStyle = .body, image: UIImage? = nil) {
        self.init(type: .system)

        setTitle(title, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: textStyle)
        tintColor = color

        setImage(image, for: .normal)
        if #available(iOS 13.0, *) {
            if image?.isSymbolImage == true {
                let symbolConfig = UIImage.SymbolConfiguration(textStyle: textStyle)
                setPreferredSymbolConfiguration(symbolConfig, forImageIn: .normal)
            }
        }

        imageView?.adjustsImageSizeForAccessibilityContentSizeCategory = true
        titleLabel?.adjustsFontForContentSizeCategory = true
        adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
}


