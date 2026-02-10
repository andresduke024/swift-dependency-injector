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

public protocol BaseMemberMacro: MemberMacro {
    static func start(
        for macro: MemberMacros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax]
}

public extension BaseMemberMacro {
    static func start(
        for macro: MemberMacros,
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = MemberMacroArguments(
            node: node,
            declaration: declaration,
            protocols: protocols,
            context: context
        )
        
        let creator = MemberMacroCreatorFactory.get(
            for: macro,
            with: arguments
        )
        
        guard try creator.validate() else { return [] }
        
        return try creator.create()
    }
}
