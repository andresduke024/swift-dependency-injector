//
//  ObservableInjectedConstructor.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 9/02/26.
//

@attached(member, names: arbitrary)
public macro ObservableInjectedConstructor(
    _ dependencies: Any...
) = #externalMacro(
    module: "SwiftDependencyInjectorMacroImplementation",
    type: "ObservableInjectedConstructorMacro"
)
