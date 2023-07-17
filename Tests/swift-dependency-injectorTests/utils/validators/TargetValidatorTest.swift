//
//  TargetValidatorTest.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import swift_dependency_injector

final class TargetValidatorTest: XCTestCase {

    private var sut: TargetValidator!
    
    override func setUpWithError() throws {
        sut = TargetValidator()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testIsRunningOnTestTarget() throws {
        let result = sut.isRunningOnTestTarget
        XCTAssertTrue(result)
    }
    
    func testCopy() throws {
        let result = sut.copy()
        XCTAssertNotNil(result)
    }
}
