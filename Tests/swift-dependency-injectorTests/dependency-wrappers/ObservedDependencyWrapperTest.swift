//
//  ObservedDependencyWrapperTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class ObservedDependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "ObservedDependencyWrapperTest")
    private var injector: Injector!
    
    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
        DependenciesContainer.reset()
    }
    
    func testUnwrapValue() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        let sut = ObservedDependencyWrapper<DummyDependencyMockProtocol>(#file, #line, injectionContext)
        
        let result = sut.unwrapValue()
        XCTAssertNotNil(result)
    }
    
    func testUnwrapValueWithValueChange() {
        injector.register(DummyDependencyMockProtocol.self, defaultDependency: DummyDependencyType.first, implementations: [
            DummyDependencyType.first : DummyDependencyOneMock.instance,
            DummyDependencyType.second : DummyDependencyTwoMock.instance
        ])
        
        let sut = ObservedDependencyWrapper<DummyDependencyMockProtocol>(#file, #line, injectionContext)
        
        let result1 = sut.unwrapValue()
        
        injector.updateDependencyKey(of: DummyDependencyMockProtocol.self, newKey: DummyDependencyType.second)
        
        let result2 = sut.unwrapValue()
        
        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
        XCTAssertNotEqual(result1?.id, result2?.id)
    }
    
    func testUnwrapValueWithErrorOnInit() {
        let newInjectionContext = InjectionContext.tests(name: "newContext")
        let injector = Injector.build(context: newInjectionContext)
        let sut = ObservedDependencyWrapper<DummyDependencyMockProtocol>(#file, #line, newInjectionContext)
        
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        
        let _ = sut.unwrapValue()
        
        XCTAssertNotNil(sut.value)
    }
    
    func testDependencyPublisingError() {
        injector.register(DummyDependencyMockProtocol.self, implementation: DummyDependencyOneMock.instance)
        
        let mockContextManager = ContextManagerMock()
        DependenciesContainer.setContextManager(mockContextManager)
        
        let sut = ObservedDependencyWrapper<DummyDependencyMockProtocol>(#file, #line, injectionContext)
        
        mockContextManager.dependenciesManager.publisher.send(completion: .failure(.abstractionAlreadyRegistered("DummyDependencyMockProtocol", injectionContext)))
        
        XCTAssertNil(sut.value)
    }
}
