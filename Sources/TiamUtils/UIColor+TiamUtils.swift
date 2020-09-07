import UIKit

public extension UIColor {
    static func random(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: alpha)
    }
}
