//
//  InjectedConstructor.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

@attached(member, names: arbitrary)
public macro InjectedConstructor(
    _ dependencies: Any...
) = #externalMacro(
    module: "SwiftDependencyInjectorMacroImplementation",
    type: "InjectedConstructor"
)
