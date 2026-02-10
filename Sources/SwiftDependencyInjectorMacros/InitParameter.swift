//
//  InitParameter.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

@attached(peer)
public macro InitParameter() = #externalMacro(
    module: "SwiftDependencyInjectorMacroImplementation",
    type: "InitParameterMacro"
)
