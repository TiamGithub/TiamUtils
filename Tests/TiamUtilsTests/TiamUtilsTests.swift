import XCTest
@testable import TiamUtils

final class TiamUtilsTests: XCTestCase {
    func testExample() {
        do {
            let red = CGFloat.random(in: 1...1.5)
            let green = CGFloat.random(in: 1...1.5)
            let blue = CGFloat.random(in: 1...1.5)
            let alpha = CGFloat.random(in: 0...1)

            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            let rgba = color.rgbComponents
            XCTAssertEqual(rgba?.red, red)
            XCTAssertEqual(rgba?.green, green)
            XCTAssertEqual(rgba?.blue, blue)
            XCTAssertEqual(rgba?.alpha, alpha)
            XCTAssertEqual(color.cgColor.alpha, alpha)
        }

        let white = UIColor.white
        let black = UIColor.black
        let green = UIColor.green
        let blue = UIColor.blue
        let cyan = UIColor.cyan
        XCTAssertEqual(blue.morphedInto(grayscale: 1, by: 1)?.rgbComponents, white.rgbComponents)
        XCTAssertEqual(blue.morphedInto(grayscale: 1, by: 0.5)?.rgbComponents, UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1).rgbComponents)
        XCTAssertEqual(blue.morphedInto(grayscale: 0, by: 1)?.rgbComponents, black.rgbComponents)
        XCTAssertEqual(blue.morphedInto(grayscale: 0, by: 0.5)?.rgbComponents, UIColor(red: 0, green: 0, blue: 0.5, alpha: 1).rgbComponents)
        XCTAssertEqual(blue.morphedIntoHSB(green, by: 0.5)?.rgbComponents, cyan.rgbComponents)
        XCTAssertEqual(green.morphedIntoHSB(blue, by: 0.5)?.rgbComponents, cyan.rgbComponents)

        let tmpurl1 = try? FileManager.default.createUniqueTemporaryDirectory()
        let tmpurl2 = try? FileManager.default.createUniqueTemporaryDirectory()
        XCTAssertNotNil(tmpurl1)
        XCTAssertNotNil(tmpurl2)
        XCTAssertNotEqual(tmpurl1, tmpurl2)
        XCTAssertEqual(tmpurl1?.deletingLastPathComponent(), URL.temporaryDirectory)

        for url in [URL.cacheDirectory, URL.temporaryDirectory, URL.applicationSupportDirectory] {
//            print(url)
            let fileAtPath = url.fileAtPath()
            XCTAssertTrue(fileAtPath.exists)
            XCTAssertTrue(fileAtPath.isDirectory)
        }
//        print(URL(fileURLWithPath: Bundle.main.bundlePath))

        let currentlyAvailableStorageCapacity = FileManager.currentlyAvailableStorageCapacity()
        let potentiallyAvailableStorageCapacity = FileManager.potentiallyAvailableStorageCapacity(forImportantUsage: true)
        XCTAssertNotNil(currentlyAvailableStorageCapacity)
        XCTAssertNotNil(potentiallyAvailableStorageCapacity)
        XCTAssertGreaterThan(currentlyAvailableStorageCapacity!, 0)
        XCTAssertGreaterThan(potentiallyAvailableStorageCapacity!, 0)
        XCTAssertGreaterThanOrEqual(potentiallyAvailableStorageCapacity!,
                                    Int64(currentlyAvailableStorageCapacity!))
    }

    @available(iOS 13.0, *)
    func testCompositionalCollectionView() {
        var dataSource: UICollectionViewDiffableDataSource<Int, Int>?
        let layout = UICollectionViewCompositionalLayout(
            section: .init(group: .horizontal(
                layoutSize: .fullRect,
                subitems: [.init(layoutSize: .fullRect)])))

        let ccvWithFooterAndHeader = CompositionalCollectionView(
            layout: layout,
            cellClass: UICollectionViewCell.self,
            headerClass: UICollectionReusableView.self,
            footerClass: UICollectionReusableView.self)
        XCTAssertTrue(ccvWithFooterAndHeader.hasRegistered.header)
        XCTAssertTrue(ccvWithFooterAndHeader.hasRegistered.footer)

        dataSource = ccvWithFooterAndHeader.makeDiffableDataSource(
            configureCell: { _,_,_,_  in },
            configureHeader: { _,_,_ in },
            configureFooter: { _,_,_ in },
            prefetchCallback: { _,_,_ in })
        XCTAssertNotNil(ccvWithFooterAndHeader.dataSource)
        XCTAssertNotNil(ccvWithFooterAndHeader.prefetchDataSource)
        XCTAssertNotNil(dataSource?.supplementaryViewProvider)

        let ccvWithoutFooterNorHeader = CompositionalCollectionView(
            layout: layout,
            cellClass: UICollectionViewCell.self)
        dataSource = ccvWithoutFooterNorHeader.makeDiffableDataSource(
            configureCell: { _,_,_,_  in },
            configureHeader: nil,
            configureFooter: nil,
            prefetchCallback: nil)
        XCTAssertNil(ccvWithoutFooterNorHeader.prefetchDataSource)
        XCTAssertNil(dataSource?.supplementaryViewProvider)

        let expectation = XCTestExpectation(description: "synchronous call")
        DispatchQueue.mainAsyncIfNeeded {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
