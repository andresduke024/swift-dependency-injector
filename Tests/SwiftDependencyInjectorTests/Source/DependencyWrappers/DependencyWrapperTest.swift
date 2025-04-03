//
//  DependencyWrapperTest.swift
//
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class DependencyWrapperTest: XCTestCase {

    private let injectionContext: InjectionContext = .tests(name: "DependencyWrapperTest")
    private var injector: Injector!

    override func setUpWithError() throws {
        injector = Injector.build(context: injectionContext)
    }

    override func tearDownWithError() throws {
        injector = nil
    }

    func testCheckInjectionErrorWhenNoDependencyHasBeenRegistered() {
        let args = DependencyWrapperArgs(file: #file, line: #line, context: injectionContext)
        
        let sut = DependencyWrapper<DummyDependencyMockProtocol>(args: args)

        sut.checkInjectionError()
        XCTAssertNil(sut.value)
    }
}
