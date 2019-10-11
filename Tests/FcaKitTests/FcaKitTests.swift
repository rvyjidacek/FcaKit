import XCTest
@testable import FcaKit

final class FcaKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FcaKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
