//
//  StringExtensionTests.swift
//  
//
//  Created by Andres Duque on 16/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class StringExtensionTests: XCTestCase {

    func testJoin() {
        let expected = "ONE:TWO:THREE"
        let result = String.join("ONE", "TWO", "THREE", separator: ":")

        XCTAssertEqual(result, expected)
    }

}
