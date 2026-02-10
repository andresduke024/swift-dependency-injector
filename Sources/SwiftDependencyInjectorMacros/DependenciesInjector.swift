//
//  DependenciesInjector.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 29/01/26.
//

@attached(
    extension,
    conformances: DependenciesInjectorProtocol,
    names: arbitrary
)
public macro DependenciesInjector(
    _ dependencies: Any...
) = #externalMacro(
    module: "SwiftDependencyInjectorMacroImplementation",
    type: "DependenciesInjectorMacro"
)
