//
//  ViewModelTest.swift
//  
//
//  Created by Andres Duque on 5/07/23.
//

import XCTest
@testable import SwiftDependencyInjector

final class ViewModelTest: XCTestCase {
    private let contextName = "ViewModel"
    private var injector: Injector!

    override func setUp() {
        injector = Injector.build(context: .tests(name: contextName))
        injector.register(NetworkManager.self) { NetworkManagerMock() }
    }

    override func tearDown() {
        injector.destroy()
    }

    func testGetDataSuccess() async throws {
        let expected = [1, 2, 3, 4]

        injector.register(Service.self) { ServiceSuccessMock() }
        let sut = ViewModel()

        await sut.loadData()

        XCTAssertEqual(sut.data, expected)
    }

    func testGetDataFail() async throws {
        let expected = [Int]()

        injector.register(Service.self) { ServiceFailMock() }
        let sut = ViewModel()

        await sut.loadData()

        XCTAssertEqual(sut.data, expected)
    }
}
