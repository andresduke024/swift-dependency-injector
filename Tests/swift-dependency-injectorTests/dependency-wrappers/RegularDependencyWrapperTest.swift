//
//  RegularDependencyWrapperTest.swift
//
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class RegularDependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "RegularDependencyWrapperTest")
    private var injector: Injector!

    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
    }

    func testUnwrapValueRegular() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = RegularDependencyWrapper<DummyDependencyMockProtocol>(.regular, .regular, #file, #line, injectionContext)

        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }

    func testUnwrapValueLazy() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = RegularDependencyWrapper<DummyDependencyMockProtocol>(.regular, .lazy, #file, #line, injectionContext)

        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }

    func testUnwrapValueSingletonInstance() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut1 = RegularDependencyWrapper<DummyDependencyMockProtocol>(.singleton, .lazy, #file, #line, injectionContext)
        let sut2 = RegularDependencyWrapper<DummyDependencyMockProtocol>(.singleton, .lazy, #file, #line, injectionContext)

        let result1 = sut1.unwrapValue()
        let result2 = sut2.unwrapValue()

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1?.id, result2?.id)
    }

    func testUnwrapValueRegularInstance() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut1 = RegularDependencyWrapper<DummyDependencyMockProtocol>(.regular, .lazy, #file, #line, injectionContext)
        let sut2 = RegularDependencyWrapper<DummyDependencyMockProtocol>(.regular, .lazy, #file, #line, injectionContext)

        let result1 = sut1.unwrapValue()
        let result2 = sut2.unwrapValue()

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1?.id, result2?.id)
    }
}
