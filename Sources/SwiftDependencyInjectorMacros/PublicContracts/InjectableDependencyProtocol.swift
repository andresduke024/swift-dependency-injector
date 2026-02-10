//
//  InjectableDependency.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

public protocol InjectableDependencyProtocol: Sendable {
    static func register()
}
