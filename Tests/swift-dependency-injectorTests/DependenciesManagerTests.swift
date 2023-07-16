//
//  DependenciesManagerTests.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import XCTest
import Combine
@testable import swift_dependency_injector

final class DependenciesManagerTests: XCTestCase {
    
    private var sut: DependenciesManager!
    private var subscribers: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        sut = DependenciesManager()
        subscribers = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        subscribers = nil
    }
    
    func testRegisterAbstractionWithImplementationsGroup() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container[expectedSavedKey])
    }
    
    func testRegisterImplementationsGroup() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container[expectedSavedKey]?.count ?? 0
        XCTAssertEqual(result, 2)
    }
    
    func testRegisterAbstractionWithOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container[expectedSavedKey])
    }
    
    func testRegisterOneImplementation() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container[expectedSavedKey]?.count ?? 0
        XCTAssertEqual(result, 1)
    }
    
    func testAddAbstractionImplementation() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third, implementation: DummyDependencyThreeMock.instance)
        
        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container[expectedSavedKey])
    }
    
    func testAddAbstractionImplementationAndCheckCount() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third, implementation: DummyDependencyThreeMock.instance)
        
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container[expectedSavedKey]?.count ?? 0
        XCTAssertEqual(result, 3)
    }
    
    func testAddAbstractionImplementations() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        sut.add(DummyDependencyMockProtocol.self, key: DummyDependencyType.third, implementation: DummyDependencyThreeMock.instance)
        
        let expectedCount = 1
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        XCTAssertEqual(sut.container.count, expectedCount)
        XCTAssertNotNil(sut.container[expectedSavedKey])
    }
    
    func testAddAbstractionImplementationsAndCheckCount() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        sut.add(DummyDependencyMockProtocol.self, implementations: [
            DummyDependencyType.third : DummyDependencyThreeMock.instance,
            DummyDependencyType.fourth : DummyDependencyFourMock.instance
        ])
        
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container[expectedSavedKey]?.count ?? 0
        XCTAssertEqual(result, 4)
    }
    
    func testUpdateDependencyKey() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let expected = DummyDependencyType.third
        sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: expected)
        
        let expectedSavedKey = String(describing: DummyDependencyMockProtocol.self)
        let result = sut.container[expectedSavedKey]?.currentKey ?? ""
        XCTAssertEqual(result, expected)
    }
    
    func testResetAllSingletons() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
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
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let dependencyOneSingleton1: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        
        sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.second)
        
        let dependencyTwoSingleton1: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        
        sut.resetSingleton(of: DummyDependencyMockProtocol.self, key: DummyDependencyType.first)
        
        let dependencyTwoSingleton2: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        
        sut.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.first)
        
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
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let dependency1: DummyDependencyMockProtocol? = sut.get(with: .regular)
        let dependency2: DummyDependencyMockProtocol? = sut.get(with: .regular)
        
        let result1 = dependency1?.id ?? "dependency1"
        let result2 = dependency2?.id ?? "dependency2"
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1, result2)
    }
    
    
    func testGetDependencyWithSingletonInjectionType() {
        sut.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let dependency1: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        let dependency2: DummyDependencyMockProtocol? = sut.get(with: .singleton)
        
        let result1 = dependency1?.id ?? "dependency1"
        let result2 = dependency2?.id ?? "dependency2"
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result1, result2)
    }
    
    func testGetPublisher() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        let result = sut.getPublisher(of: DummyDependencyMockProtocol.self)
        
        XCTAssertNotNil(result)
    }
    
    func testRequestPublisherUpdate() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        let result = sut.getPublisher(of: DummyDependencyMockProtocol.self)
        
        guard let result else {
            XCTFail("Nil publisher")
            return
        }
        
        let expectation = expectation(description: "Waiting for implementation publishing")
        
        result.sink { completion in
            expectation.fulfill()
            if case .failure = completion {
                XCTFail("Error on implementation publishig")
            }
        } receiveValue: { wrapper in
            expectation.fulfill()
        }.store(in: &subscribers)

        waitForExpectations(timeout: 1.0)
    }
    
    func testRemoveAbstraction() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        sut.remove(DummyDependencyMockProtocol.self)
        
        let result = sut.container.count
        
        XCTAssertEqual(result, 0)
    }
    
    func testClearContainer() {
        sut.register(DummyDependencyMockProtocol.self, key: DummyDependencyType.first, implementation: DummyDependencyOneMock.instance)
        
        sut.clear()
        
        let result = sut.container.count
        
        XCTAssertEqual(result, 0)
    }
}
