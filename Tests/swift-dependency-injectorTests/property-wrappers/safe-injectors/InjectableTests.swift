//
//  InjectableTests.swift
//  
//
//  Created by Andres Duque on 19/12/23.
//

import XCTest
@testable import swift_dependency_injector

final class InjectableTests: XCTestCase {
    
    @Injectable var sut: MockInjectableProtocol?
    private var injector: Injector!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        injector = Injector.build(context: .global)
    }

    override func tearDownWithError() throws {
        injector.destroy()
    }
    
    func testInjectionCompletedSuccessfully() {
        injector.register(MockInjectableProtocol.self, implementation: MockInjectable1.instance)
        
        let result = sut?.getMockData()
        
        XCTAssertEqual(result, "mock_data_1")
    }
    
    func testInjectionIncompleted() {
        injector.destroy()
        
        let result = sut?.getMockData()
        
        XCTAssertNil(result)
    }
}
