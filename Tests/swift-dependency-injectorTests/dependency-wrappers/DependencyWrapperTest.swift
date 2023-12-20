//
//  DependencyWrapperTest.swift
//
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class DependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "DependencyWrapperTest")
    private var injector: Injector!

    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
    }

    func testCheckInjectionError() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = DependencyWrapper<DummyDependencyMockProtocol>(#file, #line, injectionContext)

        sut.checkInjectionError()
        XCTAssertNil(sut.value)
    }
}
