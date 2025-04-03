//
//  DependenciesManagerTests.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

class DependenciesManagerTests: XCTestCase {

    var sut: DependenciesManager!

    override func setUpWithError() throws {
        let targetValidatorMock = TargetValidatorMock(value: false)
        sut = DependenciesManager(targetValidator: targetValidatorMock, context: .global)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testRegisterAbstractionWithImplementationsGroup() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container.get(key: expectedSavedKey))
    }

    func testRegisterImplementationsGroup() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container.get(key: expectedSavedKey)?.count ?? 0
        XCTAssertEqual(result, 2)
    }

    func testRegisterAbstractionWithOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first) { DummyDependencyOneMock() }

        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container.get(key: expectedSavedKey))
    }

    func testRegisterOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first) { DummyDependencyOneMock() }

        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container.get(key: expectedSavedKey)?.count ?? 0
        XCTAssertEqual(result, 1)
    }

    func testAddAbstractionImplementation() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third) { DummyDependencyThreeMock() }

        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container.get(key: expectedSavedKey))
    }

    func testAddAbstractionImplementationAndCheckCount() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third) { DummyDependencyThreeMock() }

        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container.get(key: expectedSavedKey)?.count ?? 0
        XCTAssertEqual(result, 3)
    }

    func testAddAbstractionImplementations() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third) { DummyDependencyThreeMock() }

        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container.get(key: expectedSavedKey))
    }

    func testAddAbstractionImplementationsAndCheckCount() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        sut.add(DummyDependencyMockProtocol.self, implementations: [
            DummyDependencyType.third: { DummyDependencyThreeMock() },
            DummyDependencyType.fourth: { DummyDependencyFourMock() }
        ])

        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container.get(key: expectedSavedKey)?.count ?? 0
        XCTAssertEqual(result, 4)
    }


    func testResetAllSingletons() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first) { DummyDependencyOneMock() }

        let dependency1: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        sut.resetSingleton(of: DummyDependencyMockProtocol.self)

        let dependency2: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        let result1 = dependency1?.id ?? "dependency1"
        let result2 = dependency2?.id ?? "dependency2"

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1, result2)
    }

    func testResetOneSingleton() {
        // TODO: Check this tests
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let dependencyOneSingleton1: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        // sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.second)

        let dependencyTwoSingleton1: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        sut.resetSingleton(of: DummyDependencyMockProtocol.self, key: DummyDependencyType.first)

        let dependencyTwoSingleton2: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        // sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.first)

        let dependencyOneSingleton2: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        let resultDependencyOneSingleton1 = dependencyOneSingleton1?.id ?? "dependency1"
        let resultDependencyOneSingleton2 = dependencyOneSingleton2?.id ?? "dependency2"

        let resultDependencyTwoSingleton1 = dependencyTwoSingleton1?.id ?? "dependency1"
        let resultDependencyTwoSingleton2 = dependencyTwoSingleton2?.id ?? "dependency2"

        XCTAssertNotEqual(resultDependencyOneSingleton1, resultDependencyOneSingleton2)
        XCTAssertEqual(resultDependencyTwoSingleton1, resultDependencyTwoSingleton2)
    }

    func testGetDependencyWithRegularInjectionType() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let dependency1: DummyDependencyMockProtocol? = sut.get(with: .regular)
        let dependency2: DummyDependencyMockProtocol? = sut.get(with: .regular)

        let result1 = dependency1?.id ?? "dependency1"
        let result2 = dependency2?.id ?? "dependency2"

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1, result2)
    }

    func testGetDependencyWithSingletonInjectionType() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let dependency1: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        let dependency2: DummyDependencyMockProtocol? = sut.get(with: .singleton)

        let result1 = dependency1?.id ?? "dependency1"
        let result2 = dependency2?.id ?? "dependency2"

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1, result2)
    }

    func testGetDependencyWithConstraintKey() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first: { DummyDependencyOneMock() },
            DummyDependencyType.second: { DummyDependencyTwoMock() }
        ])

        let result: DummyDependencyMockProtocol? = sut.get(with: .regular, key: DummyDependencyType.second)
        XCTAssertNotNil(result as? DummyDependencyTwoMock)
    }

    func testRemoveAbstraction() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first) { DummyDependencyOneMock() }

        sut.remove(DummyDependencyMockProtocol.self)

        let result = sut.container.count

        XCTAssertEqual(result, 0)
    }

    func testClearContainer() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first) { DummyDependencyOneMock() }

        sut.clear()

        let result = sut.container.count

        XCTAssertEqual(result, 0)
    }
}
