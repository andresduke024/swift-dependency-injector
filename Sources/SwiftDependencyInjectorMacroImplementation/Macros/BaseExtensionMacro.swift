//
//  BaseExtensionMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 30/01/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public protocol BaseExtensionMacro: ExtensionMacro {
    static func start(
        for macro: ExtensionMacros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        providingExtensionsOf type: (some TypeSyntaxProtocol)?,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax]
}

public extension BaseExtensionMacro {
    static func start(
        for macro: ExtensionMacros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        providingExtensionsOf type: (some TypeSyntaxProtocol)?,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let arguments = ExtensionMacroArguments(
            node: node,
            declaration: declaration,
            type: type,
            protocols: protocols,
            context: context
        )
        
        let creator = ExtensionMacroCreatorFactory.get(
            for: macro,
            with: arguments
        )
        
        guard try creator.validate() else { return [] }
        
        return try creator.create()
    }
}
