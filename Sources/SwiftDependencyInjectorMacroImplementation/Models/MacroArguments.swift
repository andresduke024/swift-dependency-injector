//
//  MacroArguments.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct MacroArguments {
    let node: AttributeSyntax
    let declaration: DeclGroupSyntax
    let protocols: [TypeSyntax]
    let context: MacroExpansionContext
    
    init(
        node: AttributeSyntax,
        declaration: DeclGroupSyntax,
        protocols: [TypeSyntax],
        context: MacroExpansionContext
    ) {
        self.node = node
        self.declaration = declaration
        self.protocols = protocols
        self.context = context
    }
}
