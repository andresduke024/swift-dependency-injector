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

protocol MacroArguments {
    var node: AttributeSyntax { get }
    var declaration: DeclGroupSyntax { get }
    var protocols: [TypeSyntax] { get }
    var context: MacroExpansionContext { get }
}


struct MemberMacroArguments: MacroArguments {
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

struct ExtensionMacroArguments: MacroArguments {
    let node: AttributeSyntax
    let declaration: DeclGroupSyntax
    let type: TypeSyntaxProtocol?
    let protocols: [TypeSyntax]
    let context: MacroExpansionContext
    
    init(
        node: AttributeSyntax,
        declaration: DeclGroupSyntax,
        type: TypeSyntaxProtocol?,
        protocols: [TypeSyntax],
        context: MacroExpansionContext
    ) {
        self.node = node
        self.declaration = declaration
        self.type = type
        self.protocols = protocols
        self.context = context
    }
}
