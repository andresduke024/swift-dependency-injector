//
//  MacroCreator.swift
//  SwiftDependencyInjector
//
//  Created by Andres Duque on 11/01/26.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

protocol MacroCreator {
    var arguments: MacroArguments { get set }
    
    func validate() throws -> Bool
    
    func create() throws -> [DeclSyntax]
    
    func diagnose(message: BaseDiagnosticMessage)
    
    init(arguments: MacroArguments)
}

extension MacroCreator {
    
    var node: AttributeSyntax { arguments.node }
    
    var declaration: DeclGroupSyntax { arguments.declaration }
    
    var protocols: [TypeSyntax] { arguments.protocols }
    
    var context: MacroExpansionContext { arguments.context }
        
    func diagnose(
        message: BaseDiagnosticMessage
    ) {
        let diagnostic = Diagnostic(
            node: arguments.node,
            message: message
        )
        
        arguments.context.diagnose(diagnostic)
    }
}
