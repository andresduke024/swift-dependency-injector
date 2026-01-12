//
//  BaseMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public protocol BaseMacro {
    static func start(
        for macro: Macros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax]
}

public extension BaseMacro {
    static func start(
        for macro: Macros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = MacroArguments(
            node: node,
            declaration: declaration,
            protocols: protocols,
            context: context
        )
        
        let creator = MacroCreatorFactory.get(
            for: macro,
            with: arguments
        )
        
        guard try creator.validate() else { return [] }
        
        return try creator.create()
    }
}
