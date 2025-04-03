import XCTest
@testable import SwiftDependencyInjector

final class AppTests: XCTestCase {

    private var sut: App!

    override func setUp() {
        super.setUp()
        sut = App()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testApp() async throws {
        let result = await sut.main()

        var isValidResult = false
        if result == [1, 2, 3, 4] || result == [5, 6, 7, 8] {
            isValidResult = true
        }

        XCTAssertTrue(isValidResult)
    }
}
