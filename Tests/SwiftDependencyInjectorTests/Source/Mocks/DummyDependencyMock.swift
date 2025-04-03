//
//  File.swift
//  
//
//  Created by Andres Duque on 15/07/23.
//

import Foundation
@testable import SwiftDependencyInjector

struct DummyDependencyType {
    static let first = "first"
    static let second = "second"
    static let third = "third"
    static let fourth = "fourth"
}

protocol DummyDependencyMockProtocol: AnyObject, Sendable {
    func sayHello()
}

extension DummyDependencyMockProtocol {
    var id: String {
        "\(Unmanaged.passUnretained(self).toOpaque())"
    }
}

final class DummyDependencyOneMock: DummyDependencyMockProtocol {
    func sayHello() {
        print("Hello from first dummy dependency")
    }
}

final class DummyDependencyTwoMock: DummyDependencyMockProtocol {
    func sayHello() {
        print("Hello from second dummy dependency")
    }
}

final class DummyDependencyThreeMock: DummyDependencyMockProtocol {
    func sayHello() {
        print("Hello from third dummy dependency")
    }
}

final class DummyDependencyFourMock: DummyDependencyMockProtocol {
    func sayHello() {
        print("Hello from fourth dummy dependency")
    }
}

struct DummyDependency: Sendable {}
