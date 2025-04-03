//
//  TypeAliasDefinitions.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 3/04/25.
//

typealias Initializer = @Sendable () -> Sendable

/// To wrap the definition of a generic implementations container.
typealias InitializersContainer = ConcurrencySafeStorage<Initializer>
