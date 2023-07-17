//
//  AbstractionMapperTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class AbstractionMapperTest: XCTestCase {
    func testMapSuccess() {
        let dependencyMock = DummyDependencyOneMock()
        let mock = dependencyMock as AnyObject
        
        let result: DummyDependencyMockProtocol? = AbstractionMapper.map(mock)
        XCTAssertNotNil(result)
    }
    
    func testMapFail() {
        let dependencyMock = DummyDependency()
        let mock = dependencyMock as AnyObject
        
        let result: DummyDependencyMockProtocol? = AbstractionMapper.map(mock)
        XCTAssertNil(result)
    }
}
