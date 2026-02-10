//
//  InjectableDependency.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

@attached(
    extension,
    conformances: InjectableDependencyProtocol,
    names: arbitrary
)
public macro InjectableDependency(
    of dependencies: Any...
) = #externalMacro(
    module: "SwiftDependencyInjectorMacroImplementation",
    type: "InjectableDependencyMacro"
)
