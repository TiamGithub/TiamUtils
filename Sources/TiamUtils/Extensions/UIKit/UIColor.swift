import UIKit

public extension UIColor {
    struct RGBComponents: Equatable {
        public let red: CGFloat
        public let green: CGFloat
        public let blue: CGFloat
        public let alpha: CGFloat
    }

    struct HSBComponents: Equatable {
        public let hue: CGFloat
        public let saturation: CGFloat
        public let brightness: CGFloat
        public let alpha: CGFloat
    }

    static func random(alpha: CGFloat = 1, range: ClosedRange<CGFloat> = 0...1) -> UIColor {
        UIColor(red: .random(in: range), green: .random(in: range), blue: .random(in: range), alpha: alpha)
    }

    var rgbComponents: RGBComponents? {
        var red = CGFloat(0), green = CGFloat(0), blue = CGFloat(0), alpha = CGFloat(0)
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return RGBComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    var hsbComponents: HSBComponents? {
        var hue = CGFloat(0), saturation = CGFloat(0), brightness = CGFloat(0), alpha = CGFloat(0)
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        return HSBComponents(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    /// Gradual change from self to a grayscale color, by a given amount
    /// - Parameters:
    ///   -  grayscale: targeted  greyscale color
    ///   - alpha: targeted  alpha color
    ///   - amount: linear value between 0 and 1, where 0 returns self and 1 returns destination
    func morphedInto(grayscale: Double, alpha: Double = 1, by amount: Double) -> UIColor? {
        guard let rgba = self.rgbComponents else {
            return nil
        }
        let grayscale = CGFloat(grayscale.clamped(to: 0...1))
        let alpha = CGFloat(alpha.clamped(to: 0...1))
        let amount = CGFloat(amount.clamped(to: 0...1))

        return UIColor.init(
            red: rgba.red + (grayscale - rgba.red) * amount,
            green: rgba.green + (grayscale - rgba.green) * amount,
            blue: rgba.blue + (grayscale - rgba.blue) * amount,
            alpha: rgba.alpha + (alpha - rgba.alpha) * amount)
    }

    /// Gradual change from self to destination, by a given amount
    /// - Parameters:
    ///   - destination: targeted color
    ///   - amount: linear value between 0 and 1, where 0 returns self and 1 returns destination
    /// - Note: RGB method, best used with a nearby color or grayscale color
    func morphedIntoRGB(_ destination: UIColor, by amount: Double) -> UIColor? {
        let amount = CGFloat(amount.clamped(to: 0...1))
        var red1 = CGFloat(0), green1 = CGFloat(0), blue1 = CGFloat(0), alpha1 = CGFloat(0)
        var red2 = CGFloat(0), green2 = CGFloat(0), blue2 = CGFloat(0), alpha2 = CGFloat(0)

        guard self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1),
              destination.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2) else {
            return nil
        }

        return UIColor(
            red: red1 + (red2 - red1) * amount,
            green: green1 + (green2 - green1) * amount,
            blue: blue1 + (blue2 - blue1) * amount,
            alpha: alpha1 + (alpha2 - alpha1) * amount)
    }

    /// Gradual change from self to destination, by a given amount
    /// - Parameters:
    ///   - destination: targeted color
    ///   - amount: linear value between 0 and 1, where 0 returns self and 1 returns destination
    /// - Note: HSB method, not suitable for grayscale color where hue is always 0 (i.e. red)
    func morphedIntoHSB(_ destination: UIColor, by amount: Double) -> UIColor? {
        let amount = CGFloat(amount.clamped(to: 0...1))
        var hue1 = CGFloat(0), saturation1 = CGFloat(0), brightness1 = CGFloat(0), alpha1 = CGFloat(0)
        var hue2 = CGFloat(0), saturation2 = CGFloat(0), brightness2 = CGFloat(0), alpha2 = CGFloat(0)

        guard self.getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1),
              destination.getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2) else {
            return nil
        }

        let absolute = abs(hue2 - hue1)
        let distance = (absolute > 0.5) ? (1 - absolute) : absolute
        let hue: CGFloat
        switch (absolute < 0.5, hue1 > hue2) {
        case (true, true), (false, false):
            hue = hue1 - distance * amount
        case (true, false), (false, true):
            hue = hue1 + distance * amount
        }

        return UIColor(
            hue: (hue + 1) - floor(hue + 1),
            saturation: saturation1 + (saturation2 - saturation1) * amount,
            brightness: brightness1 + (brightness2 - brightness1) * amount,
            alpha: alpha1 + (alpha2 - alpha1) * amount)
    }

}
