import XCTest
@testable import TiamUtils

final class TiamUtilsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testColors() {
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
    }

    func testFileManager() {
        let tmpurl1 = try? FileManager.default.createUniqueTemporaryDirectory()
        let tmpurl2 = try? FileManager.default.createUniqueTemporaryDirectory()
        XCTAssertNotNil(tmpurl1)
        XCTAssertNotNil(tmpurl2)
        XCTAssertNotEqual(tmpurl1, tmpurl2)
        XCTAssertEqual(tmpurl1?.deletingLastPathComponent(), URL.temporaryDirectory)

        let currentlyAvailableStorageCapacity = FileManager.currentlyAvailableStorageCapacity()
        let potentiallyAvailableStorageCapacity = FileManager.potentiallyAvailableStorageCapacity(forImportantUsage: true)
        XCTAssertNotNil(currentlyAvailableStorageCapacity)
        XCTAssertNotNil(potentiallyAvailableStorageCapacity)
        XCTAssertGreaterThan(currentlyAvailableStorageCapacity!, 0)
        XCTAssertGreaterThan(potentiallyAvailableStorageCapacity!, 0)
        XCTAssertGreaterThanOrEqual(potentiallyAvailableStorageCapacity!,
                                    Int64(currentlyAvailableStorageCapacity!))
    }

    func testURL() {
        for url in [URL.cacheDirectory, URL.temporaryDirectory, URL.applicationSupportDirectory] {
            let fileAtPath = url.fileAtPath()
            XCTAssertTrue(fileAtPath.exists)
            XCTAssertTrue(fileAtPath.isDirectory)
        }
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

    func testFileDownloader() {
        let fileDownloader = FileDownloader()
        let url1 = URL(string: "https://www.google.com")!
        let request1 = URLRequest(url: url1)
        let expectation1 = XCTestExpectation(description: "download successful")
        fileDownloader.startDownloadingFile(at: request1, updateHandler: { change in
            print(change)
            if case .finish(.success(let url)) = change {
                XCTAssertTrue(url.fileAtPath().exists)
                expectation1.fulfill()
            }
        })

        let url2 = URL(string: "https://www.google.com/404")!
        let request2 = URLRequest(url: url2)
        let expectation2 = XCTestExpectation(description: "404 error")
        fileDownloader.startDownloadingFile(at: request2, updateHandler: { change in
            print(change)
            if case .finish(.failure(let error)) = change {
                XCTAssertEqual((error as? HTTPURLResponse.ServerError)?.statusCode, 404)
                expectation2.fulfill()
            }
        })
        wait(for: [expectation1, expectation2], timeout: 10)
    }

    static var allTests = [
        ("testColors", testColors),
        ("testFileManager", testFileManager),
        ("testURL", testURL),
        ("testFileDownloader", testFileDownloader),
    ]
}
