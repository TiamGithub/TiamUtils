import UIKit

public extension UIColor {
    static func random(alpha: CGFloat = 1) -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha)
    }

    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return (red, green, blue, alpha)
    }

    /// Gradual change from self to destination, by a given amount
    /// - Parameters:
    ///   - destination: targeted color
    ///   - amount: linear value between 0 and 1, where 0 returns self and 1 returns destination
    func morphedInto(_ destination: UIColor, by amount: Double) -> UIColor {
        let amount = CGFloat(min(1, max(amount, 0)))

        var red1 = CGFloat(0.0), green1 = CGFloat(0.0), blue1 = CGFloat(0.0), alpha1 = CGFloat(0.0)
        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

        var red2 = CGFloat(0.0), green2 = CGFloat(0.0), blue2 = CGFloat(0.0), alpha2 = CGFloat(0.0)
        destination.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return UIColor(red: red1 + (red2 - red1) * amount,
                       green: green1 + (green2 - green1) * amount,
                       blue: blue1 + (blue2 - blue1) * amount,
                       alpha: alpha1 + (alpha2 - alpha1) * amount)
    }
}
