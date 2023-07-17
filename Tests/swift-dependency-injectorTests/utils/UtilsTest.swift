//
//  UtilsTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class UtilsTest: XCTestCase {

    private let mock = "/app/repositories/MockRepository.swift"
    
    func testCreateName() {
        let expected = "DummyDependencyMockProtocol"
        let result = Utils.createName(for: DummyDependencyMockProtocol.self)
        XCTAssertEqual(expected, result)
    }
    
    func testExtractFileNameWithExtension() {
        let expected = "MockRepository.swift"
        let result = Utils.extractFileName(of: mock, withExtension: true)
        XCTAssertEqual(expected, result)
    }
    
    func testExtractFileNameWithoutExtension() {
        let expected = "MockRepository"
        let result = Utils.extractFileName(of: mock, withExtension: false)
        XCTAssertEqual(expected, result)
    }
}
