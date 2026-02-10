//
//  SwiftDependencyInjectorMacroImplementation.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwiftDependencyInjectorMacroPlugin: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        InjectedConstructorMacro.self,
        ObservableInjectedConstructorMacro.self,
        InitParameterMacro.self,
        InjectableDependencyMacro.self,
        DependenciesInjectorMacro.self
    ]
}
