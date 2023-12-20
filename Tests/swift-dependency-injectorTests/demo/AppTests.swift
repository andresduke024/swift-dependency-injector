import XCTest
@testable import swift_dependency_injector

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

    func testApp() throws {
        let result = sut.main()

        var isValidResult = false
        if result == [1, 2, 3, 4] || result == [5, 6, 7, 8] {
            isValidResult = true
        }

        XCTAssertTrue(isValidResult)
    }
}
