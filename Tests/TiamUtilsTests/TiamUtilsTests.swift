import XCTest
@testable import TiamUtils

final class TiamUtilsTests: XCTestCase {
    func testExample() {
        let red = CGFloat.random(in: 1...1.5)
        let green = CGFloat.random(in: 1...1.5)
        let blue = CGFloat.random(in: 1...1.5)
        let alpha = CGFloat.random(in: 0...1)

        let color = UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
        let rgba = color.rgbComponents
        XCTAssert(rgba?.red == red)
        XCTAssert(rgba?.green == green)
        XCTAssert(rgba?.blue == blue)
        XCTAssert(rgba?.alpha == alpha)
        XCTAssertEqual(color.cgColor.alpha, alpha)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
