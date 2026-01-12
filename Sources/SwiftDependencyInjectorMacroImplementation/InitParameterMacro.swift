//
//  InitParameterMacro.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct InitParameterMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // This macro does NOT generate code.
        // It only acts as a marker for @InjectedConstructor.
        return []
    }
}
